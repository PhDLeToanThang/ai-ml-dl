import httpx
from httpx_ntlm import HttpNtlmAuth

from src.models.powerbi_rs import PBIRSConfig
from src.utils.logging import setup_logging

logger = setup_logging()


class PowerBIRSClient:
    """Power BI Report Server REST API v2.0 client with NTLM auth."""

    def __init__(self, config: PBIRSConfig):
        self.base_url = config.base_url.rstrip("/")
        self.auth = HttpNtlmAuth(
            f"{config.domain}\\{config.username}",
            config.password,
        )

    async def _request(self, method: str, path: str, **kwargs):
        async with httpx.AsyncClient(
            auth=self.auth,
            verify=False,
            timeout=60.0,
        ) as client:
            url = f"{self.base_url}{path}"
            logger.debug("PBIRS %s %s", method, url)
            resp = await client.request(method, url, **kwargs)
            resp.raise_for_status()
            return resp.json() if resp.text else {}

    async def list_reports(self) -> list[dict]:
        """List all Power BI reports on the server."""
        data = await self._request("GET", "/PowerBIReports")
        return data.get("value", [])

    async def get_report(self, report_id: str) -> dict:
        """Get report details by ID."""
        return await self._request("GET", f"/PowerBIReports({report_id})")

    async def upload_report(
        self,
        pbix_path: str,
        name: str,
        folder_path: str | None = None,
        overwrite: bool = False,
    ) -> dict:
        """Upload a .pbix file to the report server."""
        with open(pbix_path, "rb") as f:
            pbix_data = f.read()

        body = {
            "name": name,
            "pbix": {
                "name": f"{name}.pbix",
                "contentType": "application/octet-stream",
            },
        }
        if folder_path:
            body["folderPath"] = folder_path

        result = await self._request("POST", "/PowerBIReports", json=body)
        item_id = result.get("id")

        if item_id:
            await self._request(
                "PUT",
                f"/PowerBIReports({item_id})/Content",
                content=pbix_data,
                headers={"Content-Type": "application/octet-stream"},
            )

        logger.info("Uploaded report '%s' (id=%s)", name, item_id)
        return {"success": True, "id": item_id, "name": name}

    async def list_refresh_plans(
        self, report_id: str | None = None
    ) -> list[dict]:
        """List cache refresh plans, optionally filtered by report."""
        if report_id:
            data = await self._request(
                "GET",
                f"/PowerBIReports({report_id})/CacheRefreshPlans",
            )
        else:
            data = await self._request("GET", "/CacheRefreshPlans")
        return data.get("value", [])

    async def create_refresh_plan(
        self,
        report_id: str,
        description: str = "AionUI triggered refresh",
        schedule_type: str = "Once",
    ) -> dict:
        """Create a new cache refresh plan for a report."""
        body = {
            "description": description,
            "reportId": report_id,
            "schedule": {"type": schedule_type},
        }
        return await self._request("POST", "/CacheRefreshPlans", json=body)

    async def execute_refresh_plan(self, plan_id: str) -> dict:
        """Execute a cache refresh plan immediately."""
        return await self._request(
            "PUT",
            f"/CacheRefreshPlans({plan_id})/CacheRefreshPlan.Execute",
        )

    async def get_refresh_history(self, plan_id: str) -> list[dict]:
        """Get execution history of a refresh plan."""
        data = await self._request(
            "GET",
            f"/CacheRefreshPlans({plan_id})/History",
        )
        return data.get("value", [])

    async def list_folders(self) -> list[dict]:
        """List all folders."""
        data = await self._request("GET", "/Folders")
        return data.get("value", [])

    async def create_folder(
        self,
        name: str,
        parent_folder_id: str | None = None,
        description: str = "",
    ) -> dict:
        """Create a new folder."""
        body = {"name": name, "description": description}
        if parent_folder_id:
            body["parentFolderId"] = parent_folder_id
        return await self._request("POST", "/Folders", json=body)

    async def list_datasources(self) -> list[dict]:
        """List all data sources."""
        data = await self._request("GET", "/DataSources")
        return data.get("value", [])

    async def list_schedules(self) -> list[dict]:
        """List all schedules."""
        data = await self._request("GET", "/Schedules")
        return data.get("value", [])

    async def get_catalog_item(self, item_id: str) -> dict:
        """Get catalog item details by ID."""
        return await self._request("GET", f"/CatalogItems({item_id})")

    async def list_subscriptions(self) -> list[dict]:
        """List all subscriptions."""
        data = await self._request("GET", "/Subscriptions")
        return data.get("value", [])

    async def delete_item(self, item_id: str) -> dict:
        """Delete a catalog item."""
        return await self._request("DELETE", f"/CatalogItems({item_id})")
