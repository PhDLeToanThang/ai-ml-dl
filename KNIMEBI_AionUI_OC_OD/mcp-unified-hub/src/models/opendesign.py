from pydantic import BaseModel, Field


class OpenDesignConfig(BaseModel):
    daemon_url: str = Field(
        default="http://localhost:3080",
        description="Open Design daemon base URL"
    )
    api_key: str | None = Field(
        default=None,
        description="Optional bearer token for OD daemon"
    )


class ODSkill(BaseModel):
    id: str
    name: str
    description: str = ""


class ODProject(BaseModel):
    id: str
    name: str
    skill_id: str
    design_system_id: str | None = None
    status: str = "pending"
    brief: str = ""


class ODArtifact(BaseModel):
    project_id: str
    format: str = "html"
    download_url: str | None = None
    saved_to: str | None = None
