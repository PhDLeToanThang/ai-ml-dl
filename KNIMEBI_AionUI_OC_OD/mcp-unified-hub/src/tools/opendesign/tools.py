from mcp.server.fastmcp import FastMCP

from src.tools.opendesign.client import OpenDesignClient
from src.tools.opendesign.config import build_opendesign_config


def register_opendesign_tools(mcp: FastMCP, raw_config: dict):
    od_cfg = build_opendesign_config(raw_config.get("opendesign", {}))
    client = OpenDesignClient(od_cfg)

    @mcp.tool(
        name="opendesign_list_skills",
        description="List all available Open Design skills "
                    "(137 built-in: prototype, deck, image, video, ...). "
                    "Use a skill ID to create a design project.",
    )
    async def opendesign_list_skills() -> list[dict]:
        """Get available design skills from Open Design."""
        return await client.list_skills()

    @mcp.tool(
        name="opendesign_list_design_systems",
        description="List 150+ brand design systems "
                    "(Linear, Stripe, Vercel, Notion, Apple, ...). "
                    "Apply a system to a project for brand-consistent output.",
    )
    async def opendesign_list_design_systems() -> list[dict]:
        """Get available design systems."""
        return await client.list_design_systems()

    @mcp.tool(
        name="opendesign_generate_prototype",
        description="Create and generate a design prototype. "
                    "Specify skill, optional design system, and brief. "
                    "Returns project ID for status tracking.",
    )
    async def opendesign_generate_prototype(
        name: str,
        skill_id: str,
        brief: str,
        design_system_id: str | None = None,
    ) -> dict:
        """Generate a design prototype via Open Design.

        Args:
            name: Project name
            skill_id: Skill, e.g. 'dashboard', 'web-prototype', 'mobile-app'
            brief: Design brief (what to design, for whom, tone)
            design_system_id: Brand system, e.g. 'linear', 'stripe'
        """
        project = await client.create_project(
            name=name,
            skill_id=skill_id,
            design_system_id=design_system_id,
            brief=brief,
        )
        return await client.generate_artifact(project["id"])

    @mcp.tool(
        name="opendesign_generate_deck",
        description="Create and generate a presentation deck. "
                    "Uses 'guizang-ppt' or 'simple-deck' skills internally. "
                    "Returns project ID for export.",
    )
    async def opendesign_generate_deck(
        name: str,
        brief: str,
        deck_style: str = "guizang-ppt",
        design_system_id: str | None = None,
    ) -> dict:
        """Generate a presentation deck.

        Args:
            name: Project name
            brief: Deck content brief
            deck_style: 'guizang-ppt', 'simple-deck', 'weekly-update'
            design_system_id: Optional brand design system
        """
        project = await client.create_project(
            name=name,
            skill_id=deck_style,
            design_system_id=design_system_id,
            brief=brief,
        )
        return await client.generate_artifact(project["id"])

    @mcp.tool(
        name="opendesign_export_artifact",
        description="Export a generated artifact to file. "
                    "Supports HTML, PDF, PPTX, ZIP, Markdown. "
                    "Downloads to a local path.",
    )
    async def opendesign_export_artifact(
        project_id: str,
        format: str = "html",
        output_path: str | None = None,
    ) -> dict:
        """Export design artifact to file.

        Args:
            project_id: Project ID from generation
            format: 'html', 'pdf', 'pptx', 'zip', 'md'
            output_path: Local path to save export
        """
        return await client.export_artifact(
            project_id=project_id,
            format=format,
            output_path=output_path,
        )

    @mcp.tool(
        name="opendesign_get_project_status",
        description="Check project status and get artifact metadata. "
                    "Use after generate to check completion.",
    )
    async def opendesign_get_project_status(
        project_id: str,
    ) -> dict:
        """Get project status and artifact info."""
        project = await client.get_project(project_id)
        artifact = await client.get_artifact(project_id)
        return {"project": project, "artifact": artifact}

    @mcp.tool(
        name="opendesign_apply_design_system",
        description="Apply a design system to an existing project. "
                    "Changes the visual direction (colors, fonts, spacing).",
    )
    async def opendesign_apply_design_system(
        project_id: str,
        design_system_id: str,
    ) -> dict:
        """Apply a design system to an existing project.

        Args:
            project_id: Existing project to update
            design_system_id: Design system to apply
        """
        project = await client.create_project(
            name=f"rebrand-{project_id}",
            skill_id="tweaks",
            design_system_id=design_system_id,
            brief=f"Apply design system {design_system_id} "
                  f"to existing project {project_id}",
        )
        return project

    @mcp.tool(
        name="opendesign_list_projects",
        description="List all projects in Open Design with their "
                    "status, skill, and design system.",
    )
    async def opendesign_list_projects() -> list[dict]:
        """Get all projects from Open Design."""
        return await client.list_projects()

    @mcp.tool(
        name="opendesign_list_agents",
        description="List CLI agents detected by the Open Design daemon. "
                    "Agents like OpenCode, Claude Code are used for generation.",
    )
    async def opendesign_list_agents() -> list[dict]:
        """Get available CLI agents from Open Design."""
        return await client.list_agents()
