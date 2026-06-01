from pydantic import BaseModel, Field
from pathlib import Path


class KNIMEConfig(BaseModel):
    executable: str = Field(
        default="C:\\Program Files\\KNIME\\knime.exe",
        description="Path to KNIME executable"
    )
    workspace: str = Field(
        default="C:\\knime-workspace",
        description="Path to KNIME workspace root"
    )


class KNIMEResult(BaseModel):
    success: bool
    exit_code: int | None = None
    stdout: str = ""
    stderr: str = ""
    error: str | None = None
