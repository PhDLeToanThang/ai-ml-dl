import asyncio
import csv
import io
from pathlib import Path

from src.models.knime import KNIMEConfig, KNIMEResult
from src.utils.logging import setup_logging

logger = setup_logging()


class KNIMEExecutor:
    def __init__(self, config: KNIMEConfig):
        self.exe = Path(config.executable)
        self.workspace = Path(config.workspace)

    async def execute(
        self,
        workflow_dir: str,
        variables: dict[str, str] | None = None,
        timeout: int = 600,
    ) -> KNIMEResult:
        wf_path = self.workspace / workflow_dir
        if not wf_path.exists():
            return KNIMEResult(
                success=False,
                error=f"Workflow not found: {wf_path}",
            )

        cmd = [
            str(self.exe),
            "-nosplash",
            "-nosave",
            "-reset",
            "-application",
            "org.knime.product.KNIME_BATCH_APPLICATION",
            "-workflowDir",
            str(wf_path),
        ]

        if variables:
            for k, v in variables.items():
                cmd.extend(["-workflow.variable", f"{k},{v},String"])

        cmd.extend(["-vmargs", "-Xmx4096m"])

        logger.info("Executing KNIME workflow: %s", workflow_dir)

        try:
            proc = await asyncio.create_subprocess_exec(
                *cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
            )
            out, err = await asyncio.wait_for(
                proc.communicate(), timeout=timeout
            )

            result = KNIMEResult(
                success=proc.returncode == 0,
                exit_code=proc.returncode,
                stdout=out.decode("utf-8", errors="replace"),
                stderr=err.decode("utf-8", errors="replace"),
            )

            logger.info(
                "KNIME workflow %s: exit_code=%d",
                "succeeded" if result.success else "failed",
                result.exit_code,
            )
            return result

        except asyncio.TimeoutError:
            proc.kill()
            logger.error("KNIME workflow timed out after %ds", timeout)
            return KNIMEResult(
                success=False,
                error=f"Timeout after {timeout}s",
            )

    async def read_output_table(
        self, output_path: str, max_rows: int = 100
    ) -> list[dict]:
        file_path = self.workspace / output_path
        if not file_path.exists():
            raise FileNotFoundError(f"Output file not found: {file_path}")

        rows = []
        with open(file_path, "r", encoding="utf-8-sig") as f:
            reader = csv.DictReader(f)
            for i, row in enumerate(reader):
                if i >= max_rows:
                    break
                rows.append(row)

        return rows

    async def list_workflows(self) -> list[dict]:
        if not self.workspace.exists():
            return []

        workflows = []
        for item in self.workspace.iterdir():
            if item.is_dir():
                knime_file = item / "workflow.knime"
                if knime_file.exists():
                    workflows.append({
                        "name": item.name,
                        "path": str(item.relative_to(self.workspace)),
                    })

        return workflows

    async def get_workflow_status(
        self, workflow_dir: str
    ) -> dict:
        wf_path = self.workspace / workflow_dir
        knime_file = wf_path / "workflow.knime"
        return {
            "exists": wf_path.exists() and knime_file.exists(),
            "path": str(wf_path) if wf_path.exists() else None,
            "name": workflow_dir,
        }
