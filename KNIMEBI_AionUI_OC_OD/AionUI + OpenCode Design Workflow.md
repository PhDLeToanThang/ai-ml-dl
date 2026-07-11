# AionUI + OpenCode Design Workflow
>>> Tài liệu tổng hợp: Phương pháp dùng AIonUI và OpenCode để đọc, phân tích và chuyển đổi Office/BI templates thành các file thiết kế
`.md`, skill `.md`, agents `.md`, `mcp.json` — rồi dùng chúng để sinh báo cáo, dashboard, design mới từ dữ liệu thực tế.

---

## 1. Tổng quan kiến trúc

```
┌──────────────────────────────────────────────────────────────────┐
│                    INPUT TEMPLATES                               │
│  .docx │ .xlsx │ .pptx │ .pbix (Power BI) │ .pbit                │
└──────────────┬───────────────────────────────────────────────────┘
               │
       ┌───────▼─────────┐
       │ OfficeCLI CLI   │  officecli view | get | query | merge
       │(AionUI built-in)│
       └───────┬─────────┘
               │
       ┌───────▼─────────┐
       │  markitdown     │  Microsoft tool: Office → Markdown
       │  (pip install)  │
       └───────┬─────────┘
               │
       ┌───────▼────────────────────────────────────────┐
       │           DESIGN ARTIFACTS (.md files)         │
       │                                                │
       │  design.md   — Design system / visual rules    │
       │  skill.md    — Reusable skill definition       │
       │  agents.md   — Agent behavior rules (AGENTS.md)│
       │  mcp.json    — MCP server configuration        │
       └───────┬────────────────────────────────────────┘
               │
       ┌───────▼────────────────────────────────────────┐
       │           OUTPUT (via opencode)                │
       │                                                │
       │  Fill new data → templates                     │
       │  Generate BI reports                           │
       │  Draw / Dashboard layout                       │
       │  Office docs from templates + data             │
       └────────────────────────────────────────────────┘
```

---

## 2. Công cụ cốt lõi

### 2.1 AionUI (iOfficeAI)

- **Desktop app** — AI agent platform với built-in assistants: PPT Creator, Word Creator, Excel Creator, Dashboard Creator, UI/UX Pro Max...
- **OfficeCLI** — CLI binary không cần Office, đọc/sửa/tạo `.docx`, `.xlsx`, `.pptx`
- **Built-in Skills**: `officecli-docx`, `officecli-pptx`, `officecli-xlsx`, `officecli-data-dashboard`, `morph-ppt`
- **Preview Panel**: xem trực tiếp PDF, Word, Excel, PPT, Markdown, HTML, code — realtime
- GitHub: https://github.com/iOfficeAI/AionUi

### 2.2 OpenCode

- **CLI agent** — model-agnostic, bring-your-own-key
- **Skills system**: `.opencode/skills/<name>/SKILL.md` với YAML frontmatter
- **AGENTS.md**: project rules file, auto-loaded mỗi session
- **MCP servers**: cấu hình trong `opencode.json` under `"mcp"` key
- **Subagents**: delegate task qua `task` tool
- Docs: https://opencode.ai/docs/skills/

### 2.3 OfficeCLI

- **Commands chính**: `create`, `view`, `get`, `query`, `set`, `add`, `raw-set`, `batch`, `merge`, `validate`
- **Template merge**: `officecli merge <file> --data data.json` — thay `{{key}}` placeholders bằng JSON data
- **3 layer access**: L1 (read) → L2 (DOM edit) → L3 (raw XML)
- **Element types**: paragraph, run, table, row, cell, shape, chart, image, connector, slide, sheet, row, cell...
- GitHub: https://github.com/iOfficeAI/OfficeCLI

### 2.4 markitdown (Microsoft)

```bash
pip install markitdown
markitdown "document.docx" > output.md
markitdown "data.xlsx" > output.md
markitdown "slides.pptx" > output.md
```

- Converts Word → Markdown (headings, tables, lists, formatting)
- Converts Excel → Markdown tables
- Converts PowerPoint → sections with slides, notes
- GitHub: https://github.com/microsoft/markitdown

---

## 3. Quy trình đọc và chuyển đổi templates

### Bước 1: Đọc template bằng OfficeCLI

```bash
# Xem outline
officecli view report.docx outline
officecli view deck.pptx outline
officecli view data.xlsx outline

# Đọc chi tiết
officecli view report.docx annotated    # fonts, sizes, styles
officecli view deck.pptx text           # text dump
officecli get deck.pptx "/slide[1]" --depth 2 --json

# Query CSS-like
officecli query report.docx "p:contains('Revenue')"
officecli query deck.pptx "shape[type=textbox]"
```

### Bước 2: Chuyển sang Markdown

```bash
# Cách A: markitdown (Microsoft)
markitdown "template.docx" > design_doc.md
markitdown "template.xlsx" > design_data.md
markitdown "template.pptx" > design_ppt.md

# Cách B: OfficeCLI view → text/annotated
officecli view template.docx text > design_doc.md
officecli view template.pptx annotated > design_ppt_annotated.md

# Cách C: AionUI Preview Panel
# Mở file trực tiếp trong AionUI → Copy content → Save as .md
```

### Bước 3: Power BI Templates (.pbix / .pbit)

Power BI không đọc trực tiếp được qua CLI. Các cách tiếp cận:

```bash
# Cách 1: Extract metadata từ .pbit (ZIP-based)
# .pbit = ZIP chứa DataModelSchema, DiagramLayout, Report/Layout, ...

# Cách 2: Dùng Power BI REST API hoặc Tabular Editor
# Export metadata → JSON → convert sang Markdown

# Cách 3: Screenshot + OCR qua AionUI
# Mở Power BI Desktop → Screenshot dashboard → Feed vào AI agent
# Agent phân tích layout, KPIs, visual types → tạo design.md
```

**Workflow Power BI → Markdown:**
```
1. Mở .pbix trong Power BI Desktop
2. Screenshot từng trang dashboard
3. Export data model (Tabular Editor → .bim JSON)
4. Feed screenshots + .bim vào AionUI/OpenCode agent
5. Agent tạo design.md với:
   - Page layout (grid, vị trí visuals)
   - Visual types (bar, line, card, matrix, slicer...)
   - Data model (tables, relationships, measures)
   - Color scheme, fonts, themes
   - KPI definitions
```

---

## 4. Tạo các file Design Artifacts

### 4.1 design.md (Design System)

Tạo từ template đã phân tích:

```markdown
---
name: company-dashboard-design
description: Design system for Company BI Dashboards — colors, typography, layout rules, visual conventions
version: "1.0"
source: "template_analysis.xlsx"
---

# Dashboard Design System

## Colors
- Primary: #1E2761 (dark navy)
- Secondary: #CADCFC (light blue)
- Accent: #FF6B35 (orange)
- Background: #F8F9FA
- Text: #2D3436
- Success: #00B894
- Warning: #FDCB6E
- Error: #E17055

## Typography
- Headers: Inter Bold, 24px/20px/16px
- Body: Inter Regular, 14px
- Data labels: Inter Mono, 12px
- KPI numbers: Inter Bold, 36px

## Layout Grid
- 12-column grid
- Gutter: 16px
- Margin: 24px
- Card padding: 20px
- Card border-radius: 8px

## Visual Types
- KPI Card: big number + label + trend arrow + % change
- Bar Chart: horizontal, max 8 categories
- Line Chart: max 4 series, smooth curves
- Table: alternating row colors, sortable columns
- Donut Chart: max 6 segments, center label
- Map: choropleth with tooltip

## Conventions
- Every page has a title header + date range filter
- KPIs row at top (4 cards max)
- Charts below KPIs
- Filter sidebar on left (collapsible)
- Export button top-right
```

### 4.2 skill.md (Reusable Skill)

Tạo skill cho OpenCode/AionUI:

```markdown
---
name: dashboard-generator
description: Generate BI dashboard reports from data files using design system templates. Use when user requests dashboard creation, BI reports, or data visualization layouts.
compatibility: opencode
metadata:
  audience: data-analysts
  workflow: bi-reporting
---

# Dashboard Generator Skill

## When to use
- User provides data (CSV, Excel, database) and wants a dashboard
- User wants to fill a template with new data
- User asks for BI report generation

## Workflow

### Step 1: Load Design System
Read `design.md` from project root for colors, typography, layout rules.

### Step 2: Analyze Input Data
```
officecli view input.xlsx outline
officecli query input.xlsx "sheet[name=Data]"
```

### Step 3: Map Data to Visuals
- KPI cards → aggregate functions (SUM, AVG, COUNT)
- Trend charts → time series data
- Comparison → category + value pairs
- Detail → table with full records

### Step 4: Generate Dashboard
```bash
# Option A: HTML Dashboard
# Create responsive HTML with Chart.js/D3.js

# Option B: Excel Dashboard via OfficeCLI
officecli create dashboard.xlsx
officecli add dashboard.xlsx /Sheet1 --type chart --prop type=bar ...

# Option C: PPT Dashboard
officecli create dashboard.pptx
officecli add dashboard.pptx / --type slide --prop layout=blank
```

### Step 5: Fill Data
```bash
officecli merge template.pptx --data data.json
```

### Step 6: Verify
- Check in AionUI Preview Panel
- Validate layout, colors match design.md
- Test with different data sizes
```

### 4.3 agents.md (AGENTS.md)

```markdown
# Project AI Agent Rules

## Project Context
BI Dashboard project using AionUI + OpenCode + OfficeCLI.
Templates in `templates/` directory.
Design system in `design.md`.

## Agent Behavior
1. Always load `design.md` before generating any visual output
2. Use `officecli` for all Office file operations
3. Follow design system colors/typography strictly
4. Generate responsive layouts (test at 1280px, 1920px widths)
5. Include data validation (null handling, type checking)

## File Operations
- Read templates: `officecli view <file> outline`
- Read data: `officecli view <file> text`
- Create output: `officecli create <file>`
- Fill data: `officecli merge <template> --data <json>`
- Verify: `officecli view <file> issues`

## Design Conventions
- KPI cards: always include trend indicator (+/- arrow + %)
- Charts: max 6 categories, include legend
- Tables: max 10 rows per page, include pagination hint
- Colors: follow design.md palette only
- Fonts: Inter family only

## Output Formats
优先级:
1. `.pptx` (OfficeCLI) — presentations, slide dashboards
2. `.xlsx` (OfficeCLI) — data tables, Excel dashboards
3. `.html` — web dashboards, interactive reports
4. `.pdf` (via OfficeCLI export) — printable reports

## MCP Tools
- `officecli` — Office document manipulation
- `open-design` (optional) — UI/UX design generation
```

### 4.4 mcp.json

```json
{
  "mcp": {
    "officecli": {
      "type": "local",
      "command": ["npx", "-y", "officecli"]
    },
    "open-design": {
      "type": "local",
      "command": ["npx", "-y", "open-design-mcp"],
      "env": {
        "OD_DAEMON_URL": "http://localhost:7456",
        "BYOK_BASE_URL": "https://your-ai-proxy.example.com/v1",
        "BYOK_API_KEY": "<your-api-key>",
        "BYOK_MODEL": "gpt-4o"
      }
    },
    "designer-skill": {
      "type": "local",
      "command": ["npx", "-y", "designer-skill-mcp"]
    }
  }
}
```

---

## 5. Quy trình đầy đủ: Template → Design Artifacts → Output

### Phase 1: Phân tích Template

```bash
# 1.1 Đọc structure
officecli view template.pptx outline
officecli view template.pptx annotated --json > template_analysis.json

# 1.2 Chuyển sang Markdown
markitdown "template.pptx" > template_content.md

# 1.3 Import vào AionUI/OpenCode
# Drag & drop vào AionUI Preview Panel
# Hoặc feed content vào agent chat
```

### Phase 2: Tạo Design Artifacts

```
User: "Phân tích template này và tạo design.md, skill.md, agents.md"

Agent workflow:
1. Read template_content.md
2. Extract: colors, fonts, layout, visual types, data structure
3. Generate design.md (design system)
4. Generate skill.md (reusable generation skill)
5. Generate agents.md (agent behavior rules)
6. Save to project root
```

### Phase 3: Sử dụng để sinh Output mới

#### 3A: Fill dữ liệu mới vào template

```bash
# Tạo JSON data
cat > new_data.json << 'EOF'
{
  "title": "Q4 2026 Report",
  "date": "2026-10-01",
  "revenue": "$2.5M",
  "growth": "+18%",
  "customers": "12,450",
  "table_data": [
    {"region": "APAC", "revenue": "$1.2M", "change": "+22%"},
    {"region": "EMEA", "revenue": "$800K", "change": "+15%"},
    {"region": "Americas", "revenue": "$500K", "change": "+12%"}
  ]
}
EOF

# Merge vào template
officecli merge template.pptx --data new_data.json -o output_report.pptx
officecli merge template.docx --data new_data.json -o output_report.docx
officecli merge template.xlsx --data new_data.json -o output_report.xlsx
```

#### 3B: Tạo BI Report mới từ design.md

```
User: "Tạo dashboard BI report cho Q4 2026 với data từ sales_q4.xlsx"

Agent workflow:
1. Load skill.md (dashboard-generator)
2. Load design.md (design system)
3. Read sales_q4.xlsx: officecli view sales_q4.xlsx text
4. Create dashboard.pptx following design.md rules
5. Add KPI cards, charts, tables with real data
6. Preview in AionUI
7. Export final report
```

#### 3C: Tạo Dashboard Layout

```bash
# HTML Dashboard
officecli create dashboard.xlsx
officecli add dashboard.xlsx /Sheet1/KPI --type chart
  --prop type=bar
  --prop data='{"categories":["Q1","Q2","Q3","Q4"],"values":[1.2,1.8,2.1,2.5]}'
  --prop x=0 --prop y=0 --prop width=6 --prop height=4

# PPTX Dashboard
officecli create dashboard.pptx
officecli add dashboard.pptx / --type slide --prop layout=blank --prop background=1E2761
officecli add dashboard.pptx '/slide[1]' --type shape
  --prop text="Revenue Dashboard" --prop x=1cm --prop y=1cm
  --prop font=Arial --prop size=28 --prop color=FFFFFF
```

---

## 6. MCP Server Configuration cho OpenCode

### officecli MCP

```jsonc
// opencode.json
{
  "mcp": {
    "officecli": {
      "type": "local",
      "command": ["npx", "-y", "officecli"]
    }
  }
}
```

### open-design MCP (UI/UX)

```jsonc
{
  "mcp": {
    "open-design": {
      "type": "local",
      "command": ["npx", "-y", "open-design-mcp"],
      "env": {
        "OD_DAEMON_URL": "http://localhost:7456",
        "BYOK_BASE_URL": "https://api.openai.com/v1",
        "BYOK_API_KEY": "sk-...",
        "BYOK_MODEL": "gpt-4o"
      }
    }
  }
}
```

### designer-skill MCP

```jsonc
{
  "mcp": {
    "designer-skill": {
      "type": "local",
      "command": ["npx", "-y", "designer-skill-mcp"]
    }
  }
}
```

---

## 7. SKILL.md Frontmatter Reference (OpenCode)

```yaml
---
name: my-skill                    # lowercase, hyphens only, 1-64 chars
description: "Description here"   # 1-1024 chars, discovery signal
license: MIT                      # optional
compatibility: opencode           # optional
metadata:                         # optional string-to-string map
  audience: data-analysts
  workflow: bi-reporting
  version: "1.0"
---
```

**Skill file locations (priority order):**
```
1. .opencode/skills/<name>/SKILL.md        (project)
2. .claude/skills/<name>/SKILL.md          (project, Claude-compat)
3. ~/.config/opencode/skills/<name>/SKILL.md  (global)
4. ~/.claude/skills/<name>/SKILL.md        (global, Claude-compat)
```

---

## 8. OfficeCLI Quick Reference

### Office → Markdown (read/analyze)

```bash
# Word
officecli view report.docx outline
officecli view report.docx text
officecli view report.docx annotated
officecli get report.docx '/body/p[1]' --json

# Excel
officecli view data.xlsx outline
officecli view data.xlsx text
officecli get data.xlsx '/Sheet1/A1:B10' --json

# PowerPoint
officecli view deck.pptx outline
officecli view deck.pptx text
officecli view deck.pptx annotated
officecli get deck.pptx '/slide[1]/shape[1]' --json
```

### Create & Fill

```bash
# Create
officecli create output.pptx
officecli create output.xlsx
officecli create output.docx

# Add elements
officecli add output.pptx / --type slide --prop layout=blank
officecli add output.pptx '/slide[1]' --type shape --prop text="Hello" --prop x=1cm --prop y=1cm
officecli add output.pptx '/slide[1]' --type chart --prop type=bar --prop data='{...}'

# Template merge (fill data)
officecli merge template.pptx --data data.json -o filled.pptx
officecli merge template.docx --data data.json -o filled.docx
officecli merge template.xlsx --data data.json -o filled.xlsx

# Batch operations
officecli batch output.xlsx set '/Sheet1/A1:A100' --prop value="Updated"
```

### Validate & Debug

```bash
officecli validate output.pptx
officecli view output.pptx issues
officecli view output.pptx stats
```

---

## 9. Ví dụ thực tế: Tạo báo cáo từ Excel template

```bash
# === STEP 1: Phân tích template ===
officecli view monthly_report.xlsx outline
officecli view monthly_report.xlsx text
officecli get monthly_report.xlsx '/Sheet1' --depth 2 --json > template_structure.json

# === STEP 2: Tạo design.md từ analysis ===
# (agent hoặc thủ công tạo design.md từ template_structure.json)

# === STEP 3: Tạo skill.md cho monthly reports ===
# (agent tạo skill.md với workflow-specific instructions)

# === STEP 4: Tạo data JSON ===
cat > data_oct2026.json << 'EOF'
{
  "month": "October 2026",
  "total_revenue": "$3,200,000",
  "total_orders": "45,200",
  "avg_order_value": "$70.80",
  "top_products": [
    {"name": "Product A", "revenue": "$1,200,000", "units": "15,000"},
    {"name": "Product B", "revenue": "$800,000", "units": "12,000"},
    {"name": "Product C", "revenue": "$600,000", "units": "8,000"}
  ],
  "regions": [
    {"name": "APAC", "revenue": "$1,500,000", "growth": "+25%"},
    {"name": "EMEA", "revenue": "$1,000,000", "growth": "+18%"},
    {"name": "Americas", "revenue": "$700,000", "growth": "+12%"}
  ]
}
EOF

# === STEP 5: Fill template ===
officecli merge monthly_report.xlsx --data data_oct2026.json -o report_oct2026.xlsx
officecli merge monthly_report.pptx --data data_oct2026.json -o report_oct2026.pptx
officecli merge monthly_report.docx --data data_oct2026.json -o report_oct2026.docx

# === STEP 6: Verify ===
officecli view report_oct2026.xlsx issues
officecli view report_oct2026.pptx outline
```

---

## 10. Ví dụ: Power BI Dashboard → design.md

```
1. Mở Power BI Desktop → load .pbix file
2. Screenshot mỗi trang dashboard (Ctrl+S hoặc Snipping Tool)
3. Export data model:
   - Tabular Editor → File → Save As → Model.bim (JSON)
4. Feed vào AionUI agent:

   "Analyze these Power BI dashboard screenshots and the model.bim file.
    Create a design.md with:
    - Page layouts (grid positions of each visual)
    - Visual types used (bar, line, card, matrix, slicer, map)
    - Color theme
    - Data model (tables, columns, relationships, DAX measures)
    - Filter types and default values
    - Print/Export settings"

5. Agent outputs design.md
6. Use design.md to recreate dashboard in:
   - AionUI (interactive HTML)
   - OfficeCLI (PPTX/Excel)
   - Open Design MCP (responsive web)
```

---

## 11. Folder Structure khuyến nghị

```
project/
├── templates/                    # Office templates gốc
│   ├── monthly_report.pptx
│   ├── monthly_report.xlsx
│   ├── monthly_report.docx
│   └── dashboard_screenshots/
│       ├── page1.png
│       └── page2.png
├── design.md                     # Design system (từ template analysis)
├── AGENTS.md                     # Agent rules
├── opencode.json                 # OpenCode config + MCP
├── .opencode/
│   └── skills/
│       └── dashboard-generator/
│           └── SKILL.md          # Skill definition
├── data/                         # Input data
│   ├── data_oct2026.json
│   └── sales_q4.xlsx
├── output/                       # Generated outputs
│   ├── report_oct2026.pptx
│   ├── report_oct2026.xlsx
│   └── dashboard.html
└── AionUI_plus_OC_design.md      # Tài liệu này
```

---

## 12. Useful Links

| Resource | URL |
|----------|-----|
| AionUI | https://github.com/iOfficeAI/AionUi |
| OfficeCLI | https://github.com/iOfficeAI/OfficeCLI |
| OpenCode Docs | https://opencode.ai/docs/skills/ |
| Open Design MCP | https://github.com/nano-step/open-design-mcp |
| Designer Skill MCP | https://github.com/Pythoughts-labs/Designer-Skill |
| markitdown (Microsoft) | https://github.com/microsoft/markitdown |
| OpenCode Template | https://github.com/julianromli/opencode-template |
| Agent Skills (Addy Osmani) | https://github.com/addyosmani/agent-skills |
| oc-convert (Claude→OpenCode) | https://github.com/OpeOginni/oc-convert |
| Office to Markdown (VSCode) | https://marketplace.visualstudio.com/items?itemName=Testany.office-to-markdown |

---

## 13. Tóm tắt quy trình

```
[Template Files] ──→ [officecli/markitdown] ──→ [Markdown Analysis]
                                                     │
                                                     ▼
                                              [design.md]
                                              [skill.md]
                                              [AGENTS.md]
                                              [mcp.json]
                                                     │
                                                     ▼
                                         [OpenCode + AionUI Agent]
                                                     │
                                      ┌──────────────┼──────────────┐
                                      ▼              ▼              ▼
                              Fill new data   Create reports   Generate dashboards
                              (officecli      (officecli       (HTML/PPTX/XLSX)
                               merge)          create+add)
```
