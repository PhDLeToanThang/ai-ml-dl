# Hướng Dẫn Tích Hợp MCP — KNIME + Power BI Report Server + Open Design + AionUI

> **Tài liệu kỹ thuật chi tiết về thiết kế, cài đặt và cấu hình MCP Server trung gian cho phép AionUI tương tác với KNIME Analytics Platform, Power BI Report Server (on-premises) và Open Design (nexu-io/open-design).**

---

## Mục Lục

- [1. Kiến Trúc MCP Server Trung Gian (Unified Integration Hub)](#1-kiến-trúc-mcp-server-trung-gian-unified-integration-hub)
- [2. Thiết Kế Chi Tiết MCP Server](#2-thiết-kế-chi-tiết-mcp-server)
- [3. Cài Đặt MCP Server Trung Gian](#3-cài-đặt-mcp-server-trung-gian)
- [4. Tích Hợp KNIME Analytics Platform](#4-tích-hợp-knime-analytics-platform)
- [5. Tích Hợp Power BI Report Server (On-Premises)](#5-tích-hợp-power-bi-report-server-on-premises)
- [6. Tích Hợp Open Design (nexu-io/open-design)](#6-tích-hợp-open-design-nexu-ioopen-design)
- [7. Cấu Hình AionUI Kết Nối MCP Server](#7-cấu-hình-aionui-kết-nối-mcp-server)
- [8. Custom Skills Cho AionUI](#8-custom-skills-cho-aionui)
- [9. Tổng Kết & Kiến Trúc Vận Hành](#9-tổng-kết--kiến-trúc-vận-hành)

---

## 1. Kiến Trúc MCP Server Trung Gian (Unified Integration Hub)

### 1.1. Một MCP Server cho cả 3 nền tảng?

**Có.** Một MCP server duy nhất phục vụ cả 3 nền tảng — gọi là **Unified Integration Hub** pattern:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        AionUI Agent Layer                               │
│   ┌──────────┐  ┌──────────┐  ┌───────────┐  ┌──────────────────────┐   │
│   │ Built-in │  │ Opencode │  │ Open      │  │ Other ACP Agents     │   │
│   │ Agent    │  │          │  │ Design    │  │                      │   │
│   │          │  │          │  │ (agent)   │  │                      │   │
│   └──────────┘  └──────────┘  └───────────┘  └──────────────────────┘   │
│         │             │             │                 │                 │
│         └─────────────┴─────────────┴─────────────────┘                 │
│                              │ MCP Client                               │
│                     ┌────────▼──────────┐                               │
│                     │  AionUI MCP Hub   │                               │
│                     │  (Unified Config) │                               │
│                     └────────┬──────────┘                               │
└──────────────────────────────┼──────────────────────────────────────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
     ┌────────▼───────┐ ┌──────▼───────┐ ┌──────▼──────────┐
     │      MCP       │ │     MCP      │ │      MCP        │
     │   Tool Group   │ │  Tool Group  │ │   Tool Group    │
     │     KNIME      │ │  Power BI RS │ │   Open Design   │
     └────────┬───────┘ └──────┬───────┘ └──────┬──────────┘
              │                │                │
     ┌────────▼───────┐ ┌──────▼───────┐ ┌──────▼──────────┐
     │ KNIME Batch    │ │ PBIRS REST   │ │ OD Daemon REST  │
     │ Executor CLI   │ │ API v2.0     │ │ API (local)     │
     │ (headless)     │ │ (NTLM auth)  │ │ + Agent CLIs    │
     └────────────────┘ └──────────────┘ └─────────────────┘
```

### 1.2. Lợi ích của Unified MCP Server

| Tiêu chí | Ba MCP riêng | Một MCP trung gian |
|----------|-------------|-------------------|
| **Cấu hình AionUI** | 3 mục trong MCP config | 1 mục duy nhất |
| **Tool discover** | 3 lần `tools/list` riêng | 1 lần |
| **Cross-platform workflow** | Agent phải gọi 3 servers | Agent gọi 1 server, tự routing |
| **Authentication** | Phân tán (NTLM, token riêng) | Tập trung ở 1 class |
| **Debug & monitor** | 3 log streams | 1 log stream |
| **Deployment** | 3 services | 1 service |

### 1.3. Quan hệ giữa các nền tảng

```
                    ┌──────────┐
                    │ KNIME    │  Xử lý dữ liệu, ETL, ML models
                    │ (data)   │  Output: CSV, Excel, hình ảnh
                    └────┬─────┘
                         │ data
                    ┌────▼─────┐
             ┌──────┤ AionUI   ├──────┐
             │      │(orchestr)│      │
             │      └────┬─────┘      │
             │           │            │
      ┌──────▼───┐ ┌─────▼────┐ ┌─────▼───────┐
      │ Open     │ │ Power BI │ │ OfficeCLI   │
      │ Design   │ │ Report   │ │ (docx/pptx) │
      │ (design) │ │ Server   │ │             │
      └──────────┘ │ (report) │ └─────────────┘
                   └──────────┘
```

---

## 2. Thiết Kế Chi Tiết MCP Server

### 2.1. Lựa chọn công nghệ

| Thành phần | Lựa chọn | Lý do |
|-----------|----------|-------|
| **SDK** | Python MCP SDK v1.x (`mcp`) | FastMCP API, dễ viết, cộng đồng lớn |
| **Transport** | stdio (cho AionUI desktop) + HTTP (cho production) | stdio: 0 config, HTTP: scalable |
| **Power BI RS Auth** | `requests_ntlm` / `httpx-ntlm` | PBIRS dùng Windows/NTLM authentication |
| **Open Design Auth** | Bearer token (từ OD daemon) | OD daemon local, không cần OAuth phức tạp |

### 2.2. Cấu trúc project

```
mcp-unified-hub/
├── pyproject.toml
├── requirements.txt
├── .env.example
├── src/
│   ├── main.py                      # Entry point: FastMCP server
│   ├── tools/
│   │   ├── knime/                   # KNIME tool group
│   │   │   ├── tools.py
│   │   │   ├── executor.py
│   │   │   └── config.py
│   │   ├── powerbi_rs/              # Power BI Report Server tool group
│   │   │   ├── tools.py
│   │   │   ├── client.py            # PBIRS REST API v2.0 client
│   │   │   └── config.py
│   │   └── opendesign/              # Open Design (nexu-io) tool group
│   │       ├── tools.py
│   │       ├── client.py            # OD daemon REST API client
│   │       └── config.py
│   ├── models/                      # Pydantic models
│   │   ├── knime.py
│   │   ├── powerbi_rs.py
│   │   └── opendesign.py
│   └── utils/
│       ├── config.py
│       └── logging.py
├── config/
│   ├── knime.yaml
│   ├── powerbi_rs.yaml
│   └── opendesign.yaml
└── scripts/
    └── setup.ps1
```

### 2.3. Namespace tools

Mỗi tool đặt tên theo convention `{platform}_{action}`:

```python
# ---- KNIME Tools ----
tool(name="knime_execute_workflow")
tool(name="knime_list_workflows")
tool(name="knime_read_output_table")
tool(name="knime_get_workflow_status")

# ---- Power BI Report Server Tools ----
tool(name="powerbirs_list_reports")
tool(name="powerbirs_upload_report")
tool(name="powerbirs_refresh_dataset")
tool(name="powerbirs_list_folders")
tool(name="powerbirs_get_report_details")
tool(name="powerbirs_list_datasources")
tool(name="powerbirs_list_refresh_plans")

# ---- Open Design Tools ----
tool(name="opendesign_generate_prototype")
tool(name="opendesign_generate_deck")
tool(name="opendesign_list_skills")
tool(name="opendesign_list_design_systems")
tool(name="opendesign_export_artifact")
tool(name="opendesign_apply_design_system")
tool(name="opendesign_get_project_status")
```

### 2.4. FastMCP server skeleton

```python
# src/main.py
from mcp.server.fastmcp import FastMCP
from src.tools.knime.tools import register_knime_tools
from src.tools.powerbi_rs.tools import register_powerbirs_tools
from src.tools.opendesign.tools import register_opendesign_tools

mcp = FastMCP(
    name="aionui-integration-hub",
    instructions=(
        "Unified Integration Hub for:\n"
        "- KNIME Analytics Platform (knime_* tools)\n"
        "- Power BI Report Server on-premises (powerbirs_* tools)\n"
        "- Open Design by nexu-io (opendesign_* tools)\n\n"
        "KNIME: execute workflows headless, read output tables.\n"
        "PBIRS: manage reports, folders, datasources, trigger refresh.\n"
        "Open Design: generate prototypes/decks, apply design systems."
    ),
    version="1.0.0",
)

register_knime_tools(mcp)
register_powerbirs_tools(mcp)
register_opendesign_tools(mcp)

if __name__ == "__main__":
    mcp.run(transport="stdio")
```

---

## 3. Cài Đặt MCP Server Trung Gian

### 3.1. Yêu cầu hệ thống

| Yêu cầu | Tối thiểu |
|---------|-----------|
| Python | 3.12+ |
| uv | 0.4+ |
| RAM | 512 MB |
| KNIME | 5.9+ (Batch Executor extension) |
| Power BI Report Server | 1.25+ (REST API v2.0) |
| Open Design | 0.8.0-preview+ (daemon đang chạy) |

### 3.2. Cài đặt nhanh (Windows)

```powershell
# 1. Tạo project
mkdir mcp-unified-hub; cd mcp-unified-hub
uv venv
.venv\Scripts\activate

# 2. Cài dependencies
uv pip install mcp httpx httpx-ntlm pyyaml pydantic pywinsspi

# 3. Copy .env và điền thông số
copy .env.example .env
notepad .env
```

**File `.env` mẫu:**

```ini
# ===================== KNIME =====================
KNIME_PATH=C:\Program Files\KNIME\knime.exe
KNIME_WORKSPACE=C:\knime-workspace

# ===================== Power BI Report Server =====================
PBIRS_BASE_URL=http://pbireport01/reports/api/v2.0
PBIRS_DOMAIN=YOURDOMAIN
PBIRS_USERNAME=svc-report
PBIRS_PASSWORD=
PBIRS_AUTH=NTLM

# ===================== Open Design =====================
OPENDESIGN_DAEMON_URL=http://localhost:3080
OPENDESIGN_API_KEY=
```

### 3.3. Chạy MCP server

```powershell
# stdio mode (cho AionUI desktop)
python src\main.py

# HTTP mode (cho development)
python src\main.py --transport http --port 8081
```

---

## 4. Tích Hợp KNIME Analytics Platform

### 4.1. KNIME Batch Executor CLI

KNIME chạy workflow headless qua batch mode. Từ KNIME 5.9, cần cài **Batch Executor extension** riêng.

```powershell
# Cú pháp batch executor
& "C:\Program Files\KNIME\knime.exe" -nosplash -nosave -reset `
  -application org.knime.product.KNIME_BATCH_APPLICATION `
  -workflowDir="C:\knime-workspace\workflow-folder"

# Exit codes:
#   0 → success | 2 → sai tham số
#   3 → lỗi load workflow | 4 → lỗi execution
```

### 4.2. Python KNIME executor

```python
# src/tools/knime/executor.py
import asyncio, subprocess
from pathlib import Path

class KNIMEExecutor:
    def __init__(self, config: dict):
        self.exe = Path(config["executable"])
        self.workspace = Path(config["workspace"])

    async def execute(self, workflow_dir: str,
                      variables: dict[str, str] | None = None,
                      timeout: int = 600) -> dict:
        wf_path = self.workspace / workflow_dir
        if not wf_path.exists():
            return {"success": False,
                    "error": f"Workflow not found: {wf_path}"}

        cmd = [str(self.exe), "-nosplash", "-nosave", "-reset",
               "-application",
               "org.knime.product.KNIME_BATCH_APPLICATION",
               "-workflowDir", str(wf_path)]
        if variables:
            for k, v in variables.items():
                cmd.extend(["-workflow.variable", f"{k},{v},String"])
        cmd.extend(["-vmargs", "-Xmx4096m"])

        try:
            proc = await asyncio.create_subprocess_exec(
                *cmd, stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE)
            out, err = await asyncio.wait_for(
                proc.communicate(), timeout=timeout)
            return {
                "success": proc.returncode == 0,
                "exit_code": proc.returncode,
                "stdout": out.decode("utf-8", errors="replace"),
                "stderr": err.decode("utf-8", errors="replace"),
            }
        except asyncio.TimeoutError:
            proc.kill()
            return {"success": False,
                    "error": f"Timeout after {timeout}s"}
```

### 4.3. Tool definitions

```python
# src/tools/knime/tools.py
from mcp.server.fastmcp import FastMCP

def register_knime_tools(mcp: FastMCP):
    from src.tools.knime.executor import KNIMEExecutor
    executor = KNIMEExecutor(...)

    @mcp.tool(
        name="knime_execute_workflow",
        description="Execute a KNIME workflow headless. "
                    "Exit code 0 = success, 4 = execution error."
    )
    async def knime_execute_workflow(
        workflow_dir: str,
        variables: dict[str, str] | None = None,
        timeout: int = 600,
    ) -> dict:
        """Run a KNIME workflow in batch mode."""
        return await executor.execute(workflow_dir, variables, timeout)
```

---

## 5. Tích Hợp Power BI Report Server (On-Premises)

### 5.1. Tổng quan

Power BI Report Server (PBIRS) là giải pháp **on-premises** của Microsoft, quản lý và phân phối báo cáo nội bộ. REST API **v2.0** tại endpoint `/api/v2.0/`.

**Khác biệt với Power BI Cloud (Service):**

| Tiêu chí | Power BI Cloud (Service) | Power BI Report Server |
|----------|-------------------------|------------------------|
| **Endpoint** | `api.powerbi.com/v1.0/myorg` | `http://<server>/reports/api/v2.0` |
| **Auth** | Azure AD OAuth 2.0 | **Windows NTLM** / Forms |
| **Workspaces** | Groups/Workspaces | **Folders** |
| **Loại report** | Power BI (.pbix) | Power BI (.pbix) + Paginated (.rdl) |
| **Refresh** | REST API refresh dataset | **Cache Refresh Plan** |
| **Export** | ExportTo API (PDF/PPTX) | **Power BI Desktop lưu thủ công** |
| **Upload** | Imports API | Upload PBIX API |

### 5.2. Power BI Report Server REST API v2.0

Base URL: `http://<server>/reports/api/v2.0/`

**Các endpoints chính:**

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| `GET` | `/CatalogItems` | Danh sách tất cả items |
| `GET` | `/CatalogItems({id})` | Chi tiết item |
| `GET` | `/PowerBIReports` | Danh sách Power BI reports |
| `GET` | `/PowerBIReports({id})` | Chi tiết PBI report |
| `POST` | `/PowerBIReports({id})/Model.Upload` | Upload file .pbix |
| `GET` | `/Folders` | Danh sách folders |
| `POST` | `/Folders` | Tạo folder mới |
| `GET` | `/CacheRefreshPlans` | Danh sách refresh plans |
| `POST` | `/CacheRefreshPlans` | Tạo refresh plan |
| `GET` | `/CacheRefreshPlans({id})/History` | Lịch sử refresh |
| `PUT` | `/CacheRefreshPlans({id})/CacheRefreshPlan.Execute` | Kích hoạt refresh ngay |
| `GET` | `/DataSources` | Danh sách data sources |
| `GET` | `/Subscriptions` | Danh sách subscriptions |
| `DELETE` | `/CatalogItems({id})` | Xóa item |

### 5.3. Authentication: Windows NTLM

PBIRS dùng **Windows Authentication (NTLM)** hoặc **Forms authentication**.

```python
# src/tools/powerbi_rs/client.py
import httpx
from httpx_ntlm import HttpNtlmAuth

class PowerBIRSClient:
    """Power BI Report Server REST API v2.0 client."""

    def __init__(self, config: dict):
        self.base_url = config["base_url"].rstrip("/")
        self.auth = HttpNtlmAuth(
            f"{config['domain']}\\{config['username']}",
            config["password"],
        )

    async def _request(self, method: str, path: str, **kwargs):
        async with httpx.AsyncClient(
            auth=self.auth, verify=False, timeout=60.0
        ) as client:
            url = f"{self.base_url}{path}"
            resp = await client.request(method, url, **kwargs)
            resp.raise_for_status()
            return resp.json() if resp.text else {}

    # === Reports ===

    async def list_reports(self) -> list[dict]:
        """List all Power BI reports on the server."""
        return await self._request("GET", "/PowerBIReports")

    async def get_report(self, report_id: str) -> dict:
        """Get report details by ID."""
        return await self._request(
            "GET", f"/PowerBIReports({report_id})"
        )

    async def upload_report(
        self,
        pbix_path: str,
        name: str,
        folder_path: str | None = None,
        overwrite: bool = False,
    ) -> dict:
        """Upload a .pbix file to the report server.

        Args:
            pbix_path: Local path to .pbix file
            name: Report name on server (without .pbix)
            folder_path: Target folder path, e.g. '/Sales Reports'
            overwrite: Overwrite existing report with same name
        """
        import json
        with open(pbix_path, "rb") as f:
            pbix_data = f.read()

        # Step 1: Create catalog item entry
        body = {
            "name": name,
            "pbix": {
                "name": f"{name}.pbix",
                "contentType": "application/octet-stream",
            },
        }
        if folder_path:
            body["folderPath"] = folder_path

        # POST to create item, then upload binary
        result = await self._request(
            "POST", "/PowerBIReports",
            json=body,
        )

        # Step 2: Upload binary content
        item_id = result.get("id")
        if item_id:
            await self._request(
                "PUT",
                f"/PowerBIReports({item_id})/Content",
                content=pbix_data,
                headers={"Content-Type": "application/octet-stream"},
            )

        return {"success": True, "id": item_id, "name": name}

    # === Cache Refresh Plans ===

    async def list_refresh_plans(
        self, report_id: str | None = None
    ) -> list[dict]:
        """List cache refresh plans, optionally filtered by report."""
        if report_id:
            return await self._request(
                "GET",
                f"/PowerBIReports({report_id})/CacheRefreshPlans",
            )
        return await self._request("GET", "/CacheRefreshPlans")

    async def create_refresh_plan(
        self, report_id: str,
        description: str = "AionUI triggered refresh",
        schedule_type: str = "Once"
    ) -> dict:
        """Create a new cache refresh plan for a report.

        Args:
            report_id: Target report ID
            description: Human-readable description
            schedule_type: 'Once', 'Daily', 'Weekly', 'Monthly'
        """
        body = {
            "description": description,
            "reportId": report_id,
            "schedule": {"type": schedule_type},
        }
        return await self._request(
            "POST", "/CacheRefreshPlans", json=body
        )

    async def execute_refresh_plan(
        self, plan_id: str
    ) -> dict:
        """Execute a cache refresh plan immediately."""
        return await self._request(
            "PUT",
            f"/CacheRefreshPlans({plan_id})/"
            f"CacheRefreshPlan.Execute",
        )

    async def get_refresh_history(
        self, plan_id: str
    ) -> list[dict]:
        """Get execution history of a refresh plan."""
        return await self._request(
            "GET",
            f"/CacheRefreshPlans({plan_id})/History",
        )

    # === Folders ===

    async def list_folders(self) -> list[dict]:
        """List all folders."""
        return await self._request("GET", "/Folders")

    async def create_folder(
        self, name: str,
        parent_folder_id: str | None = None,
        description: str = "",
    ) -> dict:
        """Create a new folder.

        Args:
            name: Folder name
            parent_folder_id: Parent folder ID (None = root)
            description: Optional description
        """
        body = {"name": name, "description": description}
        if parent_folder_id:
            body["parentFolderId"] = parent_folder_id
        return await self._request("POST", "/Folders", json=body)

    # === Data Sources ===

    async def list_datasources(self) -> list[dict]:
        """List all data sources."""
        return await self._request("GET", "/DataSources")
```

### 5.4. Tool definitions cho Power BI Report Server

```python
# src/tools/powerbi_rs/tools.py
from mcp.server.fastmcp import FastMCP

def register_powerbirs_tools(mcp: FastMCP):
    from src.tools.powerbi_rs.client import PowerBIRSClient
    client = PowerBIRSClient(...)

    @mcp.tool(
        name="powerbirs_list_reports",
        description="List all Power BI reports on the Report Server. "
                    "Returns report ID, name, path, size, modified date."
    )
    async def powerbirs_list_reports() -> list[dict]:
        """Get all reports from Power BI Report Server."""
        return await client.list_reports()

    @mcp.tool(
        name="powerbirs_get_report_details",
        description="Get detailed info about a specific report "
                    "including datasources and refresh plans."
    )
    async def powerbirs_get_report_details(report_id: str) -> dict:
        """Get report details and related resources."""
        report = await client.get_report(report_id)
        plans = await client.list_refresh_plans(report_id)
        return {"report": report, "refresh_plans": plans}

    @mcp.tool(
        name="powerbirs_upload_report",
        description="Upload a .pbix file to Power BI Report Server. "
                    "Specify local path, name, and optional folder path."
    )
    async def powerbirs_upload_report(
        pbix_path: str,
        name: str,
        folder_path: str | None = None,
    ) -> dict:
        """Upload a PBIX report to the server."""
        return await client.upload_report(
            pbix_path=pbix_path, name=name,
            folder_path=folder_path,
        )

    @mcp.tool(
        name="powerbirs_refresh_dataset",
        description="Trigger a cache refresh for a report's dataset. "
                    "Creates a refresh plan if none exists, then executes it. "
                    "Use for on-premises Power BI Report Server."
    )
    async def powerbirs_refresh_dataset(
        report_id: str,
        create_plan_if_missing: bool = True,
    ) -> dict:
        """Refresh report dataset by executing cache refresh plan."""
        plans = await client.list_refresh_plans(report_id)
        if plans:
            plan_id = plans[0]["id"]
        elif create_plan_if_missing:
            plan = await client.create_refresh_plan(report_id)
            plan_id = plan["id"]
        else:
            return {"success": False,
                    "error": "No refresh plan found"}

        return await client.execute_refresh_plan(plan_id)

    @mcp.tool(
        name="powerbirs_list_folders",
        description="List all folders/categories on the Report Server. "
                    "Useful for organizing reports and navigating."
    )
    async def powerbirs_list_folders() -> list[dict]:
        """Get all folders from PBIRS."""
        return await client.list_folders()

    @mcp.tool(
        name="powerbirs_list_datasources",
        description="List all configured data sources on Report Server. "
                    "Shows connection strings and types."
    )
    async def powerbirs_list_datasources() -> list[dict]:
        """Get all data sources from PBIRS."""
        return await client.list_datasources()

    @mcp.tool(
        name="powerbirs_list_refresh_plans",
        description="List cache refresh plans for all or specific reports. "
                    "Shows schedule, last run, and next run times."
    )
    async def powerbirs_list_refresh_plans(
        report_id: str | None = None,
    ) -> list[dict]:
        """Get cache refresh plans."""
        return await client.list_refresh_plans(report_id)
```

### 5.5. Test kết nối PBIRS

```powershell
# PowerShell: Kiểm tra kết nối trước khi dùng MCP
Invoke-RestMethod -Uri "http://pbireport01/reports/api/v2.0/PowerBIReports" `
  -Credential (Get-Credential) `
  -Method Get

# Hoặc dùng ReportingServicesTools module
Install-Module -Name ReportingServicesTools
Get-RsRestReport -ReportServerUri "http://pbireport01/reports"
```

---

## 6. Tích Hợp Open Design (nexu-io/open-design)

### 6.1. Tổng quan Open Design

**Open Design** (https://github.com/nexu-io/open-design, 56.8k⭐) là nền tảng thiết kế AI mã nguồn mở — alternative cho Claude Design. Đây là một **desktop/web app** hoàn chỉnh, không phải thư viện token.

**Kiến trúc Open Design:**

```
┌─────────────────────────────────────────────────────────┐
│                   Open Design App                       │
│                                                         │
│  ┌──────────┐  ┌──────────────┐  ┌───────────────────┐  │
│  │ Web UI   │  │ Local Daemon │  │ Agent Runtime     │  │
│  │ (React)  │  │ (Node.js)    │  │ (16 CLI agents)   │  │
│  └────┬─────┘  └──────┬───────┘  │ Claude, Codex,    │  │
│       │               │          │ OpenCode, ...     │  │
│       │   REST API    │          │ (auto-detect PATH)│  │
│       │   :3080       │          └───────────────────┘  │
│       │               │                                 │
│  ┌────▼───────────────▼──────────────────────────────┐  │
│  │  137 Skills · 150 Design Systems                  │  │
│  │  Prototype · Deck · Image · Video · Audio         │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

**Các thành phần chính:**

| Thành phần | Mô tả |
|-----------|-------|
| **Daemon** | Local server (port 3080), quản lý agent runtime, skills, projects |
| **Skills (137)** | `web-prototype`, `dashboard`, `saas-landing`, `mobile-app`, `guizang-ppt`, `social-carousel`, `critique`, `tweaks`, ... |
| **Design Systems (150)** | Linear, Stripe, Vercel, Airbnb, Notion, Anthropic, Apple, Cursor, ... |
| **Visual Directions (5)** | Editorial Monocle, Modern Minimal, Tech Utility, Brutalist, Soft Warm |
| **Agents (16 CLIs)** | Claude Code, Codex, OpenCode, Qwen, Gemini CLI, Copilot, Hermes, ... |
| **Exports** | HTML, PDF, PPTX, ZIP, MP4, Markdown |

### 6.2. Open Design Daemon REST API

Open Design daemon chạy local tại `http://localhost:3080` với các endpoints:

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| `GET` | `/api/skills` | Danh sách skills |
| `GET` | `/api/design-systems` | Danh sách design systems |
| `POST` | `/api/projects` | Tạo project mới |
| `GET` | `/api/projects` | Danh sách projects |
| `GET` | `/api/projects/{id}` | Chi tiết project |
| `POST` | `/api/projects/{id}/generate` | Kích hoạt agent generate |
| `GET` | `/api/projects/{id}/artifact` | Lấy artifact kết quả |
| `POST` | `/api/projects/{id}/export` | Export artifact (PDF, PPTX, ZIP) |
| `GET` | `/api/agents` | Danh sách agents phát hiện được |

### 6.3. Python Open Design client

```python
# src/tools/opendesign/client.py
import httpx
import json
from pathlib import Path

class OpenDesignClient:
    """Client for Open Design (nexu-io) daemon REST API."""

    def __init__(self, config: dict):
        self.base_url = config["daemon_url"].rstrip("/")
        self.api_key = config.get("api_key", "")

    def _headers(self) -> dict:
        headers = {"Content-Type": "application/json"}
        if self.api_key:
            headers["Authorization"] = f"Bearer {self.api_key}"
        return headers

    async def _request(self, method: str, path: str, **kwargs):
        async with httpx.AsyncClient(timeout=300.0) as client:
            url = f"{self.base_url}{path}"
            resp = await client.request(
                method, url, headers=self._headers(), **kwargs
            )
            resp.raise_for_status()
            return resp.json() if resp.text else {}

    # === Skills ===

    async def list_skills(self) -> list[dict]:
        """List all available design skills."""
        return await self._request("GET", "/api/skills")

    # === Design Systems ===

    async def list_design_systems(self) -> list[dict]:
        """List all available design systems."""
        return await self._request("GET", "/api/design-systems")

    # === Projects ===

    async def create_project(
        self,
        name: str,
        skill_id: str,
        design_system_id: str | None = None,
        brief: str = "",
    ) -> dict:
        """Create a new design project.

        Args:
            name: Project name
            skill_id: Skill to use (e.g. 'dashboard', 'web-prototype')
            design_system_id: Optional design system (e.g. 'linear', 'stripe')
            brief: Design brief / requirements
        """
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
        return await self._request(
            "GET", f"/api/projects/{project_id}"
        )

    async def generate_artifact(self, project_id: str) -> dict:
        """Trigger agent generation for a project."""
        return await self._request(
            "POST", f"/api/projects/{project_id}/generate"
        )

    async def get_artifact(
        self, project_id: str
    ) -> dict:
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
        """Export artifact to file format.

        Args:
            project_id: Project ID
            format: 'html', 'pdf', 'pptx', 'zip', 'md'
            output_path: Local path to save the export
        """
        result = await self._request(
            "POST",
            f"/api/projects/{project_id}/export",
            json={"format": format},
        )

        if output_path and "download_url" in result:
            # Tải file từ download URL
            async with httpx.AsyncClient() as client:
                resp = await client.get(
                    f"{self.base_url}{result['download_url']}"
                )
                Path(output_path).write_bytes(resp.content)
                result["saved_to"] = output_path

        return result

    # === Agents ===

    async def list_agents(self) -> list[dict]:
        """List available CLI agents detected by Open Design."""
        return await self._request("GET", "/api/agents")
```

### 6.4. Tool definitions cho Open Design

```python
# src/tools/opendesign/tools.py
from mcp.server.fastmcp import FastMCP

def register_opendesign_tools(mcp: FastMCP):
    from src.tools.opendesign.client import OpenDesignClient
    client = OpenDesignClient(...)

    @mcp.tool(
        name="opendesign_list_skills",
        description="List all available Open Design skills "
                    "(137 built-in: prototype, deck, image, video, ...). "
                    "Use a skill ID to create a design project."
    )
    async def opendesign_list_skills() -> list[dict]:
        """Get available design skills from Open Design."""
        return await client.list_skills()

    @mcp.tool(
        name="opendesign_list_design_systems",
        description="List 150+ brand design systems "
                    "(Linear, Stripe, Vercel, Notion, Apple, ...). "
                    "Apply a system to a project for brand-consistent output."
    )
    async def opendesign_list_design_systems() -> list[dict]:
        """Get available design systems."""
        return await client.list_design_systems()

    @mcp.tool(
        name="opendesign_generate_prototype",
        description="Create and generate a design prototype. "
                    "Specify skill, optional design system, and brief. "
                    "Returns project ID for status tracking."
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
            name=name, skill_id=skill_id,
            design_system_id=design_system_id, brief=brief,
        )
        return await client.generate_artifact(project["id"])

    @mcp.tool(
        name="opendesign_generate_deck",
        description="Create and generate a presentation deck. "
                    "Uses 'guizang-ppt' or 'simple-deck' skills internally. "
                    "Returns project ID for export."
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
            name=name, skill_id=deck_style,
            design_system_id=design_system_id, brief=brief,
        )
        return await client.generate_artifact(project["id"])

    @mcp.tool(
        name="opendesign_export_artifact",
        description="Export a generated artifact to file. "
                    "Supports HTML, PDF, PPTX, ZIP, Markdown. "
                    "Downloads to a local path."
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
            project_id=project_id, format=format,
            output_path=output_path,
        )

    @mcp.tool(
        name="opendesign_get_project_status",
        description="Check project status and get artifact metadata. "
                    "Use after generate to check completion."
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
                    "Changes the visual direction (colors, fonts, spacing)."
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
        # Note: Open Design daemon handles this via project update
        project = await client.create_project(
            name=f"rebrand-{project_id}",
            skill_id="tweaks",
            design_system_id=design_system_id,
            brief=f"Apply design system {design_system_id} "
                  f"to existing project {project_id}",
        )
        return project
```

### 6.5. Luồng làm việc Open Design + AionUI

```
User: "Thiết kế dashboard doanh số cho team Sales"
  │
  ├── AionUI Agent:
  │   1. opendesign_list_skills() → chọn skill "dashboard"
  │   2. opendesign_list_design_systems() → chọn brand system
  │   3. opendesign_generate_prototype(
  │        name="Sales Dashboard Q2",
  │        skill_id="dashboard",
  │        design_system_id="stripe",
  │        brief="Dashboard cho sales team: doanh số theo tuần,
  │               top sản phẩm, pipeline, conversion rate"
  │      )
  │
  ├── Open Design Daemon:
  │   • Agent (OpenCode/Claude Code) nhận task
  │   • Sinh HTML prototype trong sandboxed iframe
  │   • Áp dụng Stripe design system (màu sắc, font, spacing)
  │
  └── Kết quả:
      opendesign_export_artifact(project_id="...", format="html")
      → File HTML dashboard, sẵn sàng cho preview hoặc nhúng
```

### 6.6. Open Design + Opencode + AionUI

Open Design đã hỗ trợ **OpenCode** như một agent engine (16 CLI agents được auto-detect):

```
┌───────────────────────────────────────────────────────┐
│                  Open Design                          │
│  ┌─────────────────────────────────────────────────┐  │
│  │ Daemon PATH scan → tự động phát hiện OpenCode   │  │
│  │ Agent Runtime → spawns: opencode <prompt>       │  │
│  │ Kết quả: HTML artifact trong project folder     │  │
│  └─────────────────────────────────────────────────┘  │
└──────────────────────┬────────────────────────────────┘
                       │ MCP: opendesign_generate_*
         ┌─────────────┴─────────────┐
         │       AionUI Agent        │
         │  (orchestrator)           │
         └───────────────────────────┘
```

Khi AionUI gọi MCP tool `opendesign_generate_prototype`, Open Design daemon có thể dùng **chính OpenCode** đã cài trên máy để thực thi thiết kế. Đây là vòng lặp cộng sinh:

1. **AionUI** điều phối (nhận lệnh user, quyết định workflow)
2. **Open Design** sinh thiết kế (dùng OpenCode hoặc Claude Code)
3. **Power BI Report Server** nhận báo cáo từ dữ liệu KNIME
4. **OfficeCLI** tạo document từ kết quả

---

## 7. Cấu Hình AionUI Kết Nối MCP Server

### 7.1. Cấu hình MCP trong AionUI

Vào **AionUI Settings → MCP Configuration** → thêm:

```json
{
  "mcpServers": {
    "integration-hub": {
      "command": "uv",
      "args": [
        "run",
        "--directory",
        "C:\\path\\to\\mcp-unified-hub",
        "python",
        "src\\main.py"
      ],
      "description": "Unified hub: KNIME + PBIRS + Open Design",
      "env": {
        "KNIME_PATH": "C:\\Program Files\\KNIME\\knime.exe",
        "KNIME_WORKSPACE": "C:\\knime-workspace",
        "PBIRS_BASE_URL": "http://pbireport01/reports/api/v2.0",
        "PBIRS_DOMAIN": "YOURDOMAIN",
        "PBIRS_USERNAME": "svc-report",
        "PBIRS_PASSWORD": "***",
        "OPENDESIGN_DAEMON_URL": "http://localhost:3080"
      }
    }
  }
}
```

### 7.2. Kiểm tra MCP server

```bash
# tools/list → phải thấy đủ tools
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```


---

## 8. Custom Skills Cho AionUI

### 8.1. Skill: Power BI Report Server

File `~/.aionui/skills/powerbi-report-server.md`:

```markdown
# Skill: powerbi-report-server

## Mô tả
Quản lý báo cáo Power BI trên Power BI Report Server (on-premises)
thông qua MCP integration hub.

## Yêu cầu
- MCP server `integration-hub` đã cấu hình
- Power BI Report Server REST API v2.0 enabled
- Tài khoản Windows domain có quyền truy cập PBIRS

## Cách sử dụng

### Liệt kê reports
powerbirs_list_reports()
→ Danh sách tất cả Power BI reports + ID, name, path

### Upload report mới
powerbirs_upload_report(
    pbix_path="C:/reports/sales.pbix",
    name="Doanh thu Q2",
    folder_path="/Phong Kinh Doanh"
)

### Refresh dataset
powerbirs_refresh_dataset(report_id="...")
→ Kích hoạt cache refresh plan cho report

### Xem folders
powerbirs_list_folders()
→ Cấu trúc thư mục trên Report Server
```

### 8.2. Skill: Open Design

File `~/.aionui/skills/open-design.md`:

```markdown
# Skill: open-design

## Mô tả
Tạo thiết kế (prototype, deck, dashboard) qua Open Design platform.
Open Design là open-source Claude Design alternative (nexu-io).

## Yêu cầu
- MCP server `integration-hub` đã cấu hình
- Open Design daemon đang chạy (pnpm tools-dev)
- Có ít nhất 1 CLI agent (OpenCode, Claude Code, ...)

## Skills phổ biến
- dashboard: admin/analytics dashboard
- web-prototype: landing page, marketing site
- mobile-app: iPhone 15 Pro framed prototype
- guizang-ppt: magazine-style presentation deck
- social-carousel: 3-card 1080×1080 carousel
- critique: 5-dimensional design critique

## Design systems phổ biến
- linear: Linear app style
- stripe: Stripe brand
- vercel: Vercel style
- notion: Notion style
- apple: Apple HIG

## Cách sử dụng

### Tạo prototype
opendesign_generate_prototype(
    name="Sales Dashboard",
    skill_id="dashboard",
    design_system_id="stripe",
    brief="Dashboard cho doanh số bán hàng theo tuần"
)

### Xuất file
opendesign_export_artifact(
    project_id="...",
    format="html",
    output_path="C:/output/dashboard.html"
)

### Tạo presentation deck
opendesign_generate_deck(
    name="Bao cao Q2",
    brief="Báo cáo tài chính quý 2 cho ban lãnh đạo",
    deck_style="guizang-ppt",
    design_system_id="linear"
)
```

---

## 9. Tổng Kết & Kiến Trúc Vận Hành

### 9.1. Sơ đồ tổng thể

```
┌──────────────────────────────────────────────────────────────────┐
│                    END-TO-END WORKFLOW                           │
│                                                                  │
│  User: "Tạo báo cáo doanh số Q2 và thiết kế dashboard"           │
│                                                                  │
│  AionUI Agent trình tự:                                          │
│                                                                  │
│  1. KNIME xử lý dữ liệu                                          │
│     knime_execute_workflow("etl-sales", {date: "2026-Q2"})       │
│     knime_read_output_table("output/sales-summary.csv")          │
│                                                                  │
│  2. Open Design thiết kế dashboard                               │
│     opendesign_generate_prototype(                               │
│       skill_id="dashboard", brief="Sales Q2 với KPIs...")        │
│     opendesign_export_artifact(format="html")                    │
│                                                                  │
│  3. Power BI Report Server refresh + upload                      │
│     powerbirs_upload_report(pbix_path="sales.pbix",              │
│       folder_path="/Bao cao dinh ky")                            │
│     powerbirs_refresh_dataset(report_id=...)                     │
│                                                                  │
│  4. OfficeCLI tạo PPT từ KNIME data (nếu cần)                    │
│     officecli merge template.pptx result.pptx ...                │
│                                                                  │
│  5. Gửi báo cáo qua Telegram/Lark                                │
└──────────────────────────────────────────────────────────────────┘
```

### 9.2. Bảng so sánh authentication

| Nền tảng | Phương thức | Cấu hình trong MCP hub |
|----------|------------|----------------------|
| **KNIME** | CLI (local process) | `KNIME_PATH`, `KNIME_WORKSPACE` |
| **Power BI RS** | Windows NTLM | `PBIRS_DOMAIN`, `PBIRS_USERNAME`, `PBIRS_PASSWORD` |
| **Open Design** | Bearer token (optional) | `OPENDESIGN_DAEMON_URL`, `OPENDESIGN_API_KEY` |

### 9.3. Pipeline tự động hóa với Cron

```
[Cron: 6:00 AM mỗi ngày]
  ├── knime_execute_workflow("daily-sales-etl")
  │   → KNIME xử lý dữ liệu, xuất CSV

[Cron: 6:30 AM]
  ├── powerbirs_refresh_dataset(report_id="sales-dashboard")
  │   → PBIRS refresh cache cho report daily

[Cron: 7:00 AM Thứ Hai]
  ├── opendesign_generate_prototype(
  │     skill_id="dashboard",
  │     brief="Weekly sales dashboard update"
  │   )
  │   opendesign_export_artifact(format="html")
  │   → Open Design tạo dashboard mới, export HTML

[Cron: 8:00 AM mỗi sáng]
  ├── AionUI agent:
  │   • KNIME data → insight
  │   • Gửi báo cáo + link Power BI + dashboard preview
  │     qua Telegram / Lark / Email
```

### 9.4. Lưu ý bảo mật

| Mối nguy | Giải pháp |
|----------|-----------|
| **PBIRS password trong env** | Dùng Windows Credential Manager hoặc service account |
| **KNIME file system** | Giới hạn scope trong KNIME workspace |
| **Open Design daemon local** | Chỉ listen localhost, không expose public |

---

> **Tài liệu tham khảo:**
> - Power BI Report Server REST API: https://learn.microsoft.com/en-us/rest/api/power-bi-report/
> - Open Design: https://github.com/nexu-io/open-design | https://open-design.ai
> - KNIME Batch Executor: https://github.com/knime-oss/knime-ap-batch
> - MCP Specification: https://modelcontextprotocol.io
> - AionUI MCP Guide: https://github.com/iOfficeAI/AionUi/wiki/MCP-Configuration-Guide
