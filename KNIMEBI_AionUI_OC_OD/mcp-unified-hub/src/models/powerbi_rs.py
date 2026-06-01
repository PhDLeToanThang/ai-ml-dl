from pydantic import BaseModel, Field


class PBIRSConfig(BaseModel):
    base_url: str = Field(
        description="PBIRS REST API base URL, e.g. http://server/reports/api/v2.0"
    )
    domain: str = Field(description="Windows domain for NTLM auth")
    username: str = Field(description="Windows username for NTLM auth")
    password: str = Field(description="Windows password for NTLM auth")
    auth: str = Field(default="NTLM", description="Auth method: NTLM or Forms")


class PBIRSReport(BaseModel):
    id: str
    name: str
    path: str = ""
    size: int = 0
    modified_date: str = ""
    created_date: str = ""


class CacheRefreshPlan(BaseModel):
    id: str
    report_id: str
    description: str = ""
    schedule_type: str = "Once"
    last_run: str | None = None
    next_run: str | None = None
