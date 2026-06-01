# MCP Unified Integration Hub

**KNIME + Power BI Report Server + Open Design** — một MCP server duy nhất cho AionUI.

## Quick Start

```powershell
powershell -ExecutionPolicy Bypass .\scripts\setup.ps1
# Edit .env with your credentials
python src\main.py
```

## Tools (19 tools, 3 platforms)

### KNIME (4 tools)
- `knime_execute_workflow` — chạy workflow headless
- `knime_list_workflows` — danh sách workflows
- `knime_read_output_table` — đọc CSV output
- `knime_get_workflow_status` — kiểm tra workflow

### Power BI Report Server (8 tools)
- `powerbirs_list_reports`, `powerbirs_get_report_details`
- `powerbirs_upload_report`, `powerbirs_refresh_dataset`
- `powerbirs_list_folders`, `powerbirs_create_folder`
- `powerbirs_list_datasources`, `powerbirs_list_refresh_plans`
- `powerbirs_get_refresh_history`

### Open Design (7 tools)
- `opendesign_list_skills`, `opendesign_list_design_systems`
- `opendesign_generate_prototype`, `opendesign_generate_deck`
- `opendesign_export_artifact`, `opendesign_get_project_status`
- `opendesign_apply_design_system`, `opendesign_list_projects`
- `opendesign_list_agents`

## AionUI Config

Add to AionUI Settings → MCP Configuration:

```json
{
  "mcpServers": {
    "integration-hub": {
      "command": "uv",
      "args": ["run", "--directory", "C:\\path\\to\\mcp-unified-hub", "python", "src\\main.py"],
      "env": {}
    }
  }
}
```

## Pipeline Automation

```powershell
# Daily pipeline: KNIME → PBIRS → Open Design
python scheduler\pipeline_daily.py

# Register as Windows Scheduled Task
.\scheduler\register_task.ps1 -ProjectDir "C:\path\to\mcp-unified-hub"
```

## Project Structure

```
mcp-unified-hub/
├── src/
│   ├── main.py                    # FastMCP server entry point
│   ├── tools/
│   │   ├── knime/                 # KNIME tool group
│   │   ├── powerbi_rs/            # PBIRS tool group
│   │   └── opendesign/            # Open Design tool group
│   ├── models/                    # Pydantic models
│   └── utils/                     # Config & logging
├── config/                        # YAML config files
├── skills/                        # AionUI custom skills
├── scheduler/                     # Pipeline automation
└── scripts/                       # Setup scripts
```
