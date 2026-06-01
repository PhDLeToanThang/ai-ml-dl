"""
Daily pipeline scheduler for KNIME + Power BI + Open Design integration.

Usage:
    python scheduler\pipeline_daily.py                  # Run full daily pipeline
    python scheduler\pipeline_daily.py --dry-run        # Preview steps without executing
    python scheduler\pipeline_daily.py --step knime     # Run only KNIME step

Schedule (Windows Task Scheduler):
    $action = New-ScheduledTaskAction -Execute "python" -Argument "C:\mcp-unified-hub\scheduler\pipeline_daily.py"
    $trigger = New-ScheduledTaskTrigger -Daily -At 06:00AM
    Register-ScheduledTask -TaskName "AionUI-DailyPipeline" -Action $action -Trigger $trigger
"""

import argparse
import asyncio
import json
import os
import sys
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from src.tools.knime.executor import KNIMEExecutor
from src.tools.knime.config import build_knime_config
from src.tools.powerbi_rs.client import PowerBIRSClient
from src.tools.powerbi_rs.config import build_pbirs_config
from src.tools.opendesign.client import OpenDesignClient
from src.tools.opendesign.config import build_opendesign_config
from src.utils.config import load_config
from src.utils.logging import setup_logging

logger = setup_logging()

REPORT_DIR = Path(__file__).resolve().parent.parent / "reports"


async def step_knime(raw_config: dict) -> bool:
    knime_cfg = build_knime_config(raw_config.get("knime", {}))
    executor = KNIMEExecutor(knime_cfg)

    logger.info("[KNIME] Executing daily-sales-etl...")
    result = await executor.execute(
        "daily-sales-etl",
        variables={"report_date": datetime.now().strftime("%Y-%m-%d")},
    )

    if not result.success:
        logger.error("[KNIME] Failed: %s", result.stderr[:500])
        return False

    logger.info("[KNIME] Success (exit=%d)", result.exit_code)
    return True


async def step_powerbi(raw_config: dict) -> bool:
    pbirs_cfg = build_pbirs_config(raw_config.get("powerbi_rs", {}))
    if pbirs_cfg is None:
        logger.warning("[PBIRS] Skipped: no configuration")
        return True

    client = PowerBIRSClient(pbirs_cfg)

    report_id = os.getenv("PBIRS_SALES_REPORT_ID", "")
    if not report_id:
        logger.warning("[PBIRS] Skipped: PBIRS_SALES_REPORT_ID not set")
        return True

    logger.info("[PBIRS] Refreshing dataset for report %s...", report_id)
    plans = await client.list_refresh_plans(report_id)
    if plans:
        plan_id = plans[0]["id"]
        result = await client.execute_refresh_plan(plan_id)
        logger.info("[PBIRS] Refresh triggered: %s", json.dumps(result))
        return True

    logger.info("[PBIRS] No refresh plan found, creating one...")
    plan = await client.create_refresh_plan(report_id)
    result = await client.execute_refresh_plan(plan["id"])
    logger.info("[PBIRS] Refresh created+triggered: %s", json.dumps(result))
    return True


async def step_opendesign(raw_config: dict) -> bool:
    od_cfg = build_opendesign_config(raw_config.get("opendesign", {}))
    client = OpenDesignClient(od_cfg)

    logger.info("[OD] Generating daily dashboard...")
    project = await client.create_project(
        name=f"Daily Sales Dashboard {datetime.now().strftime('%Y-%m-%d')}",
        skill_id="dashboard",
        brief="Daily sales performance dashboard update "
              f"for {datetime.now().strftime('%Y-%m-%d')}",
    )

    result = await client.generate_artifact(project["id"])
    logger.info("[OD] Generation triggered: %s", json.dumps(result))

    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    output_path = str(
        REPORT_DIR / f"daily-dashboard-{datetime.now().strftime('%Y%m%d')}.html"
    )

    export = await client.export_artifact(
        project_id=project["id"],
        format="html",
        output_path=output_path,
    )
    logger.info("[OD] Dashboard saved to %s", export.get("saved_to"))
    return True


async def main():
    parser = argparse.ArgumentParser(description="Daily pipeline scheduler")
    parser.add_argument("--dry-run", action="store_true", help="Preview steps only")
    parser.add_argument(
        "--step",
        choices=["knime", "powerbi", "opendesign", "all"],
        default="all",
        help="Specific step to run",
    )
    args = parser.parse_args()

    config = load_config()

    steps = {
        "knime": ("KNIME ETL", step_knime),
        "powerbi": ("PBIRS Refresh", step_powerbi),
        "opendesign": ("OD Dashboard", step_opendesign),
    }

    if args.dry_run:
        logger.info("=== DRY RUN: Pipeline Steps ===")
        for key, (label, _) in steps.items():
            logger.info("  [%s] %s", key, label)
        return

    logger.info("=== Daily Pipeline Start ===")
    start = datetime.now()

    failures = []
    for key, (label, step_fn) in steps.items():
        if args.step != "all" and args.step != key:
            continue

        logger.info("--- %s ---", label)
        try:
            ok = await step_fn(config)
            if not ok:
                failures.append(key)
        except Exception as e:
            logger.exception("[%s] Unhandled error: %s", key, e)
            failures.append(key)

    elapsed = (datetime.now() - start).total_seconds()
    if failures:
        logger.error(
            "Pipeline completed with %d failure(s): %s (%.1fs)",
            len(failures), failures, elapsed,
        )
    else:
        logger.info("Pipeline completed successfully (%.1fs)", elapsed)

    return 1 if failures else 0


if __name__ == "__main__":
    exit_code = asyncio.run(main())
    sys.exit(exit_code)
