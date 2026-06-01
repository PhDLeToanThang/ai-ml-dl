from mcp.server.fastmcp import FastMCP

from src.tools.powerbi_rs.client import PowerBIRSClient
from src.tools.powerbi_rs.config import build_pbirs_config


def register_powerbirs_tools(mcp: FastMCP, raw_config: dict):
    pbirs_cfg = build_pbirs_config(raw_config.get("powerbi_rs", {}))
    if pbirs_cfg is None:
        return

    client = PowerBIRSClient(pbirs_cfg)

    @mcp.tool(
        name="powerbirs_list_reports",
        description="List all Power BI reports on the Report Server. "
                    "Returns report ID, name, path, size, modified date.",
    )
    async def powerbirs_list_reports() -> list[dict]:
        """Get all reports from Power BI Report Server."""
        return await client.list_reports()

    @mcp.tool(
        name="powerbirs_get_report_details",
        description="Get detailed info about a specific report "
                    "including datasources and refresh plans.",
    )
    async def powerbirs_get_report_details(report_id: str) -> dict:
        """Get report details and related resources."""
        report = await client.get_report(report_id)
        plans = await client.list_refresh_plans(report_id)
        return {"report": report, "refresh_plans": plans}

    @mcp.tool(
        name="powerbirs_upload_report",
        description="Upload a .pbix file to Power BI Report Server. "
                    "Specify local path, name, and optional folder path.",
    )
    async def powerbirs_upload_report(
        pbix_path: str,
        name: str,
        folder_path: str | None = None,
    ) -> dict:
        """Upload a PBIX report to the server.

        Args:
            pbix_path: Local path to the .pbix file
            name: Report name on server (without .pbix)
            folder_path: Optional target folder like '/Sales Reports'
        """
        return await client.upload_report(
            pbix_path=pbix_path,
            name=name,
            folder_path=folder_path,
        )

    @mcp.tool(
        name="powerbirs_refresh_dataset",
        description="Trigger a cache refresh for a report's dataset. "
                    "Creates a refresh plan if none exists, then executes it. "
                    "Use for on-premises Power BI Report Server.",
    )
    async def powerbirs_refresh_dataset(
        report_id: str,
        create_plan_if_missing: bool = True,
    ) -> dict:
        """Refresh report dataset by executing cache refresh plan.

        Args:
            report_id: Report ID to refresh
            create_plan_if_missing: Auto-create plan if none exists
        """
        plans = await client.list_refresh_plans(report_id)
        if plans:
            plan_id = plans[0]["id"]
        elif create_plan_if_missing:
            plan = await client.create_refresh_plan(report_id)
            plan_id = plan["id"]
        else:
            return {"success": False, "error": "No refresh plan found"}

        return await client.execute_refresh_plan(plan_id)

    @mcp.tool(
        name="powerbirs_list_folders",
        description="List all folders/categories on the Report Server. "
                    "Useful for organizing reports and navigating.",
    )
    async def powerbirs_list_folders() -> list[dict]:
        """Get all folders from PBIRS."""
        return await client.list_folders()

    @mcp.tool(
        name="powerbirs_list_datasources",
        description="List all configured data sources on Report Server. "
                    "Shows connection strings and types.",
    )
    async def powerbirs_list_datasources() -> list[dict]:
        """Get all data sources from PBIRS."""
        return await client.list_datasources()

    @mcp.tool(
        name="powerbirs_list_refresh_plans",
        description="List cache refresh plans for all or specific reports. "
                    "Shows schedule, last run, and next run times.",
    )
    async def powerbirs_list_refresh_plans(
        report_id: str | None = None,
    ) -> list[dict]:
        """Get cache refresh plans.

        Args:
            report_id: Optional report ID to filter by
        """
        return await client.list_refresh_plans(report_id)

    @mcp.tool(
        name="powerbirs_create_folder",
        description="Create a new folder on Power BI Report Server. "
                    "Optionally specify a parent folder ID.",
    )
    async def powerbirs_create_folder(
        name: str,
        description: str = "",
        parent_folder_id: str | None = None,
    ) -> dict:
        """Create a new folder on PBIRS.

        Args:
            name: Folder name
            description: Optional description
            parent_folder_id: Optional parent folder ID
        """
        return await client.create_folder(
            name=name,
            description=description,
            parent_folder_id=parent_folder_id,
        )

    @mcp.tool(
        name="powerbirs_get_refresh_history",
        description="Get execution history of a cache refresh plan. "
                    "Shows status, start time, end time of past runs.",
    )
    async def powerbirs_get_refresh_history(
        plan_id: str,
    ) -> list[dict]:
        """Get refresh plan execution history.

        Args:
            plan_id: The cache refresh plan ID
        """
        return await client.get_refresh_history(plan_id)
