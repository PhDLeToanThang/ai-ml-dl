from pathlib import Path

import httpx

from src.models.opendesign import OpenDesignConfig
from src.utils.logging import setup_logging

logger = setup_logging()


class OpenDesignClient:
    """Client for Open Design (nexu-io) daemon REST API."""

    def __init__(self, config: OpenDesignConfig):
        self.base_url = config.daemon_url.rstrip("/")
        self.api_key = config.api_key

    def _headers(self) -> dict:
        headers = {"Content-Type": "application/json"}
        if self.api_key:
            headers["Authorization"] = f"Bearer {self.api_key}"
        return headers

    async def _request(self, method: str, path: str, **kwargs):
        async with httpx.AsyncClient(timeout=300.0) as client:
            url = f"{self.base_url}{path}"
            logger.debug("OD %s %s", method, url)
            resp = await client.request(
                method, url, headers=self._headers(), **kwargs
            )
            resp.raise_for_status()
            return resp.json() if resp.text else {}

    async def list_skills(self) -> list[dict]:
        """List all available design skills (137 built-in)."""
        return await self._request("GET", "/api/skills")

    async def list_design_systems(self) -> list[dict]:
        """List all available design systems (150+)."""
        return await self._request("GET", "/api/design-systems")

    async def create_project(
        self,
        name: str,
        skill_id: str,
        design_system_id: str | None = None,
        brief: str = "",
    ) -> dict:
        """Create a new design project."""
        body = {
            "name": name,
            "skillId": skill_id,
            "brief": brief,
        }
        if design_system_id:
            body["designSystemId"] = design_system_id
        return await self._request("POST", "/api/projects", json=body)

    async def list_projects(self) -> list[dict]:
        """List all projects in Open Design."""
        return await self._request("GET", "/api/projects")

    async def get_project(self, project_id: str) -> dict:
        """Get project details including status."""
        return await self._request("GET", f"/api/projects/{project_id}")

    async def generate_artifact(self, project_id: str) -> dict:
        """Trigger agent generation for a project."""
        return await self._request(
            "POST", f"/api/projects/{project_id}/generate"
        )

    async def get_artifact(self, project_id: str) -> dict:
        """Get generated artifact content/metadata."""
        return await self._request(
            "GET", f"/api/projects/{project_id}/artifact"
        )

    async def export_artifact(
        self,
        project_id: str,
        format: str = "html",
        output_path: str | None = None,
    ) -> dict:
        """Export artifact to file format."""
        result = await self._request(
            "POST",
            f"/api/projects/{project_id}/export",
            json={"format": format},
        )

        if output_path and "download_url" in result:
            async with httpx.AsyncClient() as client:
                resp = await client.get(
                    f"{self.base_url}{result['download_url']}"
                )
                Path(output_path).write_bytes(resp.content)
                result["saved_to"] = output_path
                logger.info("Artifact saved to %s", output_path)

        return result

    async def list_agents(self) -> list[dict]:
        """List available CLI agents detected by Open Design."""
        return await self._request("GET", "/api/agents")

    async def list_visual_directions(self) -> list[dict]:
        """List available visual directions."""
        return await self._request("GET", "/api/visual-directions")
