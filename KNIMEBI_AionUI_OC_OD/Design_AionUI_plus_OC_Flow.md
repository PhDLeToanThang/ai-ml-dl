# Design_AionUI_plus_OC_Flow.md

## Tài liệu Tổng quan & Phân tích Giải pháp

**Bộ lọc:** AionUi + OpenCode cho Kiểm toán Nội bộ Ngân hàng/Chứng khoán
**Phiên bản:** 1.0 | **Ngày:** 2026-07-11

---

## 1. Tổng quan Kiến trúc Hệ thống

```
+======================================================================+
|                        AionUi DESKTOP (GUI)                          |
|  +----------------------------------------------------------------+  |
|  |  Welcome Screen → Agent Picker → Conversation Workspace        |  |
|  |  [Built-in Agent] [OpenCode] [Claude Code] [Codex] [...]       |  |
|  +----------------------------------------------------------------+  |
|  |  Assistants Bar:                                               |  |
|  |  [Cowork] [PPT Creator] [Word Creator] [Excel Creator]         |  |
|  |  [Dashboard Creator] [Financial Model] [Custom: AuditBot]      |  |
|  +----------------------------------------------------------------+  |
|  |  Skills Panel:                                                 |  |
|  |  [docx] [xlsx] [pptx] [pdf] [mermaid] [ocr] [custom-audit]     |  |
|  +----------------------------------------------------------------+  |
|  |Preview Panel: PDF | Word | Excel | PPT | Code | Markdown | HTML|  |
|  +----------------------------------------------------------------+  |
+======================================================================+
         |                   |                    |
    +----v------+     +------v------+     +-------v-------+
    | MCP Server|     | OpenCode    |     | File System   |
    | (Tools)   |     | Engine      |     | (Templates)   |
    +-----------+     +-------------+     +---------------+
         |                   |                    |
    +----v-------------------v--------------------v----+
    |          LOCAL MACHINE (Dữ liệu KHÔNG rời PC)    |
    |  Templates/   Output/   Skills/   Agents/        |
    |  .docx  .xlsx  .pptx  .pbix  .md  .json          |
    +--------------------------------------------------+
```

---

## 2. Luồng Xử lý Chi tiết (Flow Diagrams)

### 2.1 LUỒNG 1: Đọc & Chuyển đổi Template → .md (Kịch bản 1)

```
[Kịch bản 1: Import Templates Audit]
============================================================

  INPUT: Các file mẫu đã phê duyệt
  +---------------------------+
  | templates/banking/        |
  |  ├── audit_report.docx    |
  |  ├── risk_assessment.xlsx |
  |  ├── quarterly_review.pptx|
  |  ├── financial_dash.pbix  |
  |  └── compliance_check.pptx|
  +---------------------------+
              |
              v
  +--------------------------------------------------------+
  |  BƯỚC 1: Mở AionUi → Chọn OpenCode Agent               |
  |  +---------------------------------------------------+ |
  |  | Chat Prompt:                                      | |
  |  | "Đọc tất cả file trong thư mục ./templates/       | |
  |  |  Phân tích cấu trúc nội dung từng file:           | |
  |  |  - Tiêu đề, phụ đề, logic flow                    | |
  |  |  - Các ô dữ liệu / input fields                   | |
  |  |  - Công thức Excel (nếu có)                       | |
  |  |  - Layout slide PowerPoint (nếu có)               | |
  |  |  Quy đổi sang định dạng .md với format chuẩn"     | |
  |  +---------------------------------------------------+ |
  +--------------------------------------------------------+
              |
              v
  +-------------------------------------------------------+
  |  BƯỚC 2: OpenCode + Built-in Agent xử lý              |
  |                                                       |
  |  2a. Dùng MCP Server: filesystem + OCR                |
  |      → Đọc .docx qua OfficeCLI skill (docx)           |
  |      → Đọc .xlsx qua OfficeCLI skill (xlsx)           |
  |      → Đọc .pptx qua OfficeCLI skill (pptx)           |
  |      → .pbix/.pbit: OCR screenshot + metadata parse   |
  |                                                       |
  |  2b. Agent phân tích nội dung theo domain:            |
  |      → Nhận diện: Kiểm toán nội bộ, Tuân thủ,         |
  |        Đánh giá rủi ro, Báo cáo tài chính             |
  |                                                       |
  |  2c. Viết output .md theo cấu trúc:                   |
  |      → Design.md: Design system + layout rules        |
  |      → skills.md: Quy tắc nghiệp vụ audit             |
  |      → agents.md: Agent behaviors cho auditor         |
  |      → MCP_local.md: Cấu hình tool kết nối            |
  +-------------------------------------------------------+
              |
              v
  +--------------------------------------------------------+
  |  BƯỚC 3: Output Files                                  |
  |  +---------------------------------------------------+ |
  |  | project-root/                                     | |
  |  |  ├── .opencode/                                   | |
  |  |  │   ├── agents/                                  | |
  |  |  │   │   ├── audit-reporter.md                    | |
  |  |  │   │   ├── risk-analyst.md                      | |
  |  |  │   │   └── compliance-checker.md                | |
  |  |  │   ├── skills/                                  | |
  |  |  │   │   ├── bank-audit-report/SKILL.md           | |
  |  |  │   │   ├── risk-assessment/SKILL.md             | |
  |  |  │   │   ├── financial-review/SKILL.md            | |
  |  |  │   │   └── powerbi-dashboard/SKILL.md           | |
  |  |  │   └── opencode.json                            | |
  |  |  ├── templates/  (gốc giữ nguyên)                 | |
  |  |  ├── design/                                      | |
  |  |  │   ├── Design_BankAudit.md                      | |
  |  |  │   ├── Design_RiskAssessment.md                 | |
  |  |  │   └── Design_FinancialReport.md                | |
  |  |  ├── agents/                                      | |
  |  |  │   ├── AGENTS.md                                | |
  |  |  │   ├── agents.md (học từ templates)             | |
  |  |  │   └── skills.md (quy tắc nghiệp vụ)            | |
  |  |  └── mcp_local_config.md                          | |
  |  +---------------------------------------------------+ |
  +--------------------------------------------------------+
```

### 2.2 LUỒNG 2: Tạo Báo cáo Từ Templates (Kịch bản 2)

```
[Kịch bản 2: Tạo Báo cáo Mới]
============================================================

  INPUT: Dữ liệu mới + Template .md hoặc gốc
  +---------------------------+
  | data/                     |
  |  ├── so_tai_khoan.csv     |
  |  ├── giao_dich_q4.xlsx    |
  |  ├── rui_ro_2026.xlsx     |
  |  └── bao_cao_tai_chinh.csv|
  +---------------------------+
              |
              v
  +--------------------------------------------------------+
  |  BƯỚC 1: Chat Prompt trong AionUi + OpenCode           |
  |                                                        |
  |  +---------------------------------------------------+ |
  |  | Prompt 1 - Điền dữ liệu vào Word template:        | |
  |  |                                                   | |
  |  | "Sử dụng template audit_report.docx,              | |
  |  |  đọc dữ liệu từ data/so_tai_khoan.csv,            | |
  |  |  và data/giao_dich_q4.xlsx,                       | |
  |  |  điền vào các placeholder {{field_name}}          | |
  |  |  trong template.Tạo file audit_report_2026Q4.docx | |
  |  |  Đảm bảo format giữ nguyên layout template gốc"   | |
  |  +---------------------------------------------------+ |
  |                                                        |
  |  +---------------------------------------------------+ |
  |  | Prompt 2 - Tạo báo cáo Excel:                     | |
  |  |                                                   | |
  |  | "Đọc template risk_assessment.xlsx,               | |
  |  |  lấy dữ liệu từ data/rui_ro_2026.xlsx,            | |
  |  |  cập nhật các sheet theo đúng format template.    | |
  |  |  Thêm chart biểu đồ cột thể hiện xu hướng rủi ro. | |
  |  |  Tạo file risk_assessment_final.xlsx"             | |
  |  +---------------------------------------------------+ |
  |                                                        |
  |  +---------------------------------------------------+ |
  |  | Prompt 3 - Tạo PowerPoint trình bày:              | |
  |  |                                                   | |
  |  | "Dựa trên template quarterly_review.pptx,         | |
  |  |  tạo bài trình bày quý 4/2026 với nội dung:       | |
  |  |  Slide 1: Tiêu đề + Logo ngân hàng                | |
  |  |  Slide 2: Tổng quan kết quả kinh doanh            | |
  |  |  Slide 3: Phân tích rủi ro (chart)                | |
  |  |  Slide 4: Kiểm toán nội bộ - phát hiện            | |
  |  |  Slide 5: Khuyến nghị + action items              | |
  |  |  Tạo file quarterly_review_Q4_2026.pptx"          | |
  |  +---------------------------------------------------+ |
  |                                                        |
  |  +---------------------------------------------------+ |
  |  | Prompt 4 - Tạo Dashboard Power BI:                | |
  |  |                                                   | |
  |  | "Tạo file Design_PowerBI_Dashboard.md             | |
  |  |  mô tả design dashboard Power BI cho:             | |
  |  |  - Trang 1: Tổng quan tài chính (KPIs)            | |
  |  |  - Trang 2: Phân tích rủi ro (heat map)           | |
  |  |  - Trang 3: Kết quả kiểm toán (bar + line chart)  | |
  |  |  - Trang 4: Tuân thủ pháp luật (donut chart)      | |
  |  |  bao gồm: measures DAX, data model,               | |
  |  |  color scheme, layout dimensions.                 | |
  |  |  Tạo file .pbit template cho Power BI"            | |
  |  +---------------------------------------------------+ |
  |                                                        |
  |  +---------------------------------------------------+ |
  |  | Prompt 5 - Đặt lịch tự động (Cron):               | |
  |  |                                                   | |
  |  | "Đặt lịch chạy task hàng ngày lúc 8:00 AM:        | |
  |  |  Đọc dữ liệu mới nhất từ data/                    | |
  |  |  Cập nhật báo cáo audit_report_monthly.docx       | |
  |  |  Gửi thông báo qua Telegram khi hoàn thành"       | |
  |  +---------------------------------------------------+ |
  +--------------------------------------------------------+
              |
              v
  +-------------------------------------------------------+
  |  BƯỚC 2: OpenCode Agent Xử lý                         |
  |                                                       |
  |  2a. Đọc template .md (hoặc .docx gốc qua OfficeCLI)  |
  |                                                       |
  |  2b. Load Skill tương ứng:                            |
  |      → "bank-audit-report" skill                      |
  |      → "risk-assessment" skill                        |
  |      → "powerbi-dashboard" skill                      |
  |                                                       |
  |  2c. Dùng MCP Tools:                                  |
  |      → OfficeCLI: tạo .docx / .xlsx / .pptx           |
  |      → Filesystem: đọc/ghi file                       |
  |      → Cron MCP: đặt lịch tự động                     |
  |                                                       |
  |  2d. Parallel Sessions trong AionUi:                  |
  |      Tab 1: Tạo Word report (Agent 1)                 |
  |      Tab 2: Tạo Excel report (Agent 2)                |
  |      Tab 3: Tạo PPT slides (Agent 3)                  |
  |      Tab 4: Design Power BI (Agent 4)                 |
  +-------------------------------------------------------+
              |
              v
  +-------------------------------------------------------+
  |  BƯỚC 3: Output + Preview                             |
  |                                                       |
  |  AionUi Preview Panel hiển thị ngay:                  |
  |  +--------------------------------------------------+ |
  |  |  audit_report_2026Q4.docx  ← Word Preview        | |
  |  |  risk_assessment_final.xlsx ← Excel Preview      | |
  |  |  quarterly_review_Q4.pptx   ← PPT Preview        | |
  |  |  dashboard_spec.md          ← Markdown Preview   | |
  |  +--------------------------------------------------+ |
  |                                                       |
  |  Git Version History: tự động snapshot trước khi edit |
  |  → Rollback nếu kết quả không đúng                    |
  +-------------------------------------------------------+
```

### 2.3 LUỒNG 3: Hệ thống Skill + Agent + MCP (Cấu hình)

```
[OpenCode Architecture cho Audit Project]
============================================================

  +-------------------------------------------------------+
  |  AGENTS.md (Project Root)                             |
  |  "Đây là project kiểm toán nội bộ ngân hàng.          |
  |   Tuân thủ chuẩn ISO 19011, Thông tư 05/2017.         |
  |   Mọi báo cáo phải đúng format theo template đã phê   |
  |   duyệt. Không thay đổi layout mà không có approval." |
  +-------------------------------------------------------+
              |
              v
  +-------------------------------------------------------+
  |  opencode.json (Config)                               |
  |                                                       |
  |  {                                                    |
  |    "agent": {                                         |
  |      "audit-reporter": {                              |
  |        "mode": "primary",                             |
  |        "model": "anthropic/claude-sonnet-4-20250514", |
  |        "prompt": "{file:./prompts/audit_prompt.txt}", |
  |        "permission": {                                |
  |          "edit": "ask",                               |
  |          "bash": "allow"                              |
  |        }                                              |
  |      },                                               |
  |      "risk-analyst": {                                |
  |        "mode": "subagent",                            |
  |        "model": "google/gemini-3-pro-preview",        |
  |        "permission": { "edit": "allow" }              |
  |      }                                                |
  |    },                                                 |
  |    "mcp": {                                           |
  |      "office-files": {                                |
  |        "type": "local",                               |
  |        "command": ["officecli"],                      |
  |        "enabled": true                                |
  |      },                                               |
  |      "filesystem": {                                  |
  |        "type": "local",                               |
  |        "command": ["npx","-y",                        |
  |          "@modelcontextprotocol/server-filesystem",   |
  |          "./templates", "./output"]                   |
  |      }                                                |
  |    }                                                  |
  |  }                                                    |
  +-------------------------------------------------------+
              |
              v
  +-------------------------------------------------------+
  |  .opencode/skills/ (Custom Skills)                    |
  |                                                       |
  |  bank-audit-report/SKILL.md                           |
  |  ┌─────────────────────────────────────────────────┐  |
  |  │ ---                                             │  |
  |  │ name: bank-audit-report                         │  |
  |  │ description: Đọc và tạo báo cáo kiểm toán       │  |
  |  │   nội bộ ngân hàng theo template đã duyệt       │  |
  |  │ ---                                             │  |
  |  │                                                 │  |
  |  │ ## Quy tắc:                                     │  |
  |  │ - Luôn dùng template gốc từ templates/          │  |
  |  │ - Giữ nguyên layout, chỉ thay dữ liệu           │  |
  |  │ - Thêm watermark "Confidential" trên mỗi trang  │  |
  |  │ - Đánh số trang theo format: Page X of Y        │  |
  |  │                                                 │  |
  |  │ ## Placeholder format:                          │  |
  |  │ - {{TEN_CO_HOI}} - Tên đơn vị kiểm toán         │  |
  |  │ - {{KY_BAO_CAO}} - Kỳ báo cáo                   │  |
  |  │ - {{NGUOI_KIEM_TOAN}} - Kiểm toán viên          │  |
  |  │ - {{SO_TAI_KHOAN}} - Số tài khoản               │  |
  |  │ - {{TONG_TAI_SAN}} - Tổng tài sản               │  |
  |  │ - {{RUI_RO_MAIN}} - Rủi ro chính                │  |
  |  │                                                 │  |
  |  │ ## Output format:                               │  |
  |  │ - File .docx qua OfficeCLI                      │  |
  |  │ - File .xlsx cho data tables                    │  |
  |  │ - File .pptx cho presentation                   │  |
  |  └─────────────────────────────────────────────────┘  |
  |                                                       |
  |  risk-assessment/SKILL.md                             |
  |  ┌─────────────────────────────────────────────────┐  |
  |  │ ---                                             │  |
  |  │ name: risk-assessment                           │  |
  |  │ description: Đánh giá rủi ro ngân hàng          │  |
  |  │ ---                                             │  |
  |  │ ## Risk Matrix:                                 │  |
  |  │ - Impact: 1-5 (Thấp → Rất cao)                  │  |
  |  │ - Likelihood: 1-5 (Rất thấp → Rất cao)          │  |
  |  │ - Risk Score = Impact × Likelihood              │  |
  |  │ - Level: <5 An toàn | 5-10 Trung bình | >10 Cao │  |
  |  │                                                 │  |
  |  │ ## Chart output:                                │  |
  |  │ - Heat map matrix (Excel chart)                 │  |
  |  │ - Trend line (Power BI style)                   │  |
  |  └─────────────────────────────────────────────────┘  |
  |                                                       |
  |  powerbi-dashboard/SKILL.md                           |
  |  ┌─────────────────────────────────────────────────┐  |
  |  │ ---                                             │  |
  |  │ name: powerbi-dashboard                         │  |
  |  │ description: Thiết kế dashboard Power BI        │  |
  |  │   cho báo cáo tài chính ngân hàng               │  |
  |  │ ---                                             │  |
  |  │ ## Design rules:                                │  |
  |  │ - Theme: Dark navy + Gold accent                │  |
  |  │ - Font: Segoe UI Bold headers                   │  |
  |  │ - KPI cards: 4 columns top row                  │  |
  |  │ - Charts: max 6 per page                        │  |
  |  │ - Drill-through: từ tổng quan → chi tiết        │  |
  |  │                                                 │  |
  |  │ ## DAX Measures:                                │  |
  |  │ - Total Revenue = SUM(Table[Revenue])           │  |
  |  │ - YoY Growth = (Current - Previous)/Previous    │  |
  |  │ - Risk Score = SUM(Table[RiskWeight])           │  |
  |  │                                                 │  |
  |  │ ## Output:                                      │  |
  |  │ - Design_PowerBI_Dashboard.md (spec)            │  |
  |  │ - .pbit template file (nếu OfficeCLI hỗ trợ)    │  |
  |  └─────────────────────────────────────────────────┘  |
  +-------------------------------------------------------+
```

---

## 3. Chi tiết Prompt Templates

### 3.1 Prompts cho Kịch bản 1: Đọc & Chuyển đổi

#### Prompt A: Đọc file Word (.docx)
```
Đọc file templates/audit_report.docx bằng skill docx.

Phân tích và trích xuất:
1. TOC (Table of Contents) - Cấu trúc mục lục
2. Tất cả placeholder dạng {{...}} hoặc [điền vào đây]
3. Các bảng biểu (table) - số cột, header, format số
4. Header/Footer - nội dung tĩnh
5. Style: font, size, heading levels
6. Hình ảnh/Logo (ghi chú vị trí)

Output: Tạo file templates_md/audit_report.md với format:
- Mỗi section.heading = ## Heading
- Mỗi {{placeholder}} giữ nguyên + giải thích ý nghĩa
- Mỗi table = Markdown table skeleton
- Ghi chú [LOGO: vị trí, kích thước]
- Ghi chú [STYLE: font-size-color]
```

#### Prompt B: Đọc file Excel (.xlsx)
```
Đọc file templates/risk_assessment.xlsx bằng skill xlsx.

Phân tích và trích xuất:
1. Danh sách tất cả sheet names
2. Với mỗi sheet: header row, data types, column widths
3. Tất cả công thức Excel (SUM, VLOOKUP, IF...) → chuyển sang mô tả
4. Conditional formatting rules
5. Charts definitions (type, data range, titles)
6. Data validation rules (dropdown lists, ranges)

Output: Tạo file templates_md/risk_assessment.md với format:
- ## Sheet: [tên sheet]
- ### Headers: | Col1 | Col2 | ...
- ### Formulas: [ô A1] = SUM(B1:B10) → "Tổng cột B"
- ### Validation: Col3 = dropdown [A, B, C, D]
- ### Chart: Bar chart từ data A1:D20, title "Risk Trend"
```

#### Prompt C: Đọc file PowerPoint (.pptx)
```
Đọc file templates/quarterly_review.pptx bằng skill pptx.

Phân tích và trích xuất:
1. Số lượng slides + title mỗi slide
2. Layout template (title slide, content, 2-column, blank)
3. Placeholder text → giữ nguyên hoặc đánh dấu [DATA]
4. Chart placeholders → ghi chú type mong muốn
5. Master slide theme: colors, fonts, backgrounds
6. Image/Logo positions

Output: Tạo file templates_md/quarterly_review.md với format:
- ## Slide 1: [Title] - Layout: title-slide
- ## Slide 2: [Content] - Layout: content-with-header
- [CHART: Bar chart, data source: risk_data.xlsx]
- [IMAGE: Logo top-right, 200x80px]
- [THEME: Navy #1B3A5C + Gold #C9A227]
```

#### Prompt D: Đọc file Power BI (.pbix/.pbit)
```
Đọc file templates/financial_dash.pbix.

Lưu ý: .pbix là binary, không đọc trực tiếp được.
Hãy thực hiện:
1. Nếu có .pbit (template): extract metadata
2. Nếu không: yêu cầu user chụp screenshot các trang dashboard
3. Phân tích screenshot để trích xuất:
   - Số trang (pages) + tên
   - Các visuals trên mỗi trang (type, position, size)
   - Data model relationships (nếu hiển thị)
   - Color theme
   - Filter/slicer positions

Output: Tạo file templates_md/financial_dash.md với format:
- ## Page: [tên trang]
- ### Visuals:
  - [KPI CARD] Position:(x,y) Size:(w×h) Measure: [Total Revenue]
  - [BAR CHART] Position:(x,y) Axis: [Month], Values: [Revenue]
  - [HEAT MAP] Position:(x,y) Matrix: [Risk×Impact]
- ### Data Model:
  - Table: Transactions → Columns: Date, Amount, Type
  - Relationship: Transactions[AccountID] → Accounts[ID]
- ### Theme: #1B3A5C (navy), #FFFFFF (white bg), #C9A227 (accent)
```

### 3.2 Prompts cho Kịch bản 2: Tạo Báo cáo

#### Prompt E: Điền dữ liệu vào Word Template
```
Sử dụng skill "bank-audit-report" đã tạo.

Bước 1: Đọc template audit_report.md (đã chuyển ở kịch bản 1)
Bước 2: Đọc dữ liệu nguồn:
  - data/so_tai_khoan.csv
  - data/giao_dich_q4.xlsx

Bước 3: Ghép dữ liệu vào template:
  - {{TEN_CO_HOI}} = "Ngân hàng TMCP XYZ"
  - {{KY_BAO_CAO}} = "Q4/2026"
  - {{SO_TAI_KHOAN}} = Tổng số từ CSV
  - {{TONG_TAI_SAN}} = SUM từ Excel
  - ... (tất cả placeholders)

Bước 4: Tạo file .docx output bằng OfficeCLI
  - Đảm bảo giữ nguyên layout template gốc
  - Font: Times New Roman 13pt body, Heading 16pt Bold
  - Page size: A4
  - Margin: 2.5cm all sides
  - Thêm watermark "BẢN THÔNG BÁO - CONFIDENTIAL"

Lưu output: output/audit_report_2026Q4.docx
```

#### Prompt F: Tạo Excel Report với Charts
```
Sử dụng skill "risk-assessment" đã tạo.

Bước 1: Đọc template risk_assessment.md
Bước 2: Đọc data/rui_ro_2026.xlsx (dữ liệu mới)

Bước 3: Tạo file Excel mới với OfficeCLI (xlsx skill):
  - Sheet 1 "Risk Matrix": Ma trận rủi ro 5×5
    + Rows: Mức độ Impact (1-5)
    + Cols: Mức độ Likelihood (1-5)
    + Cells: Risk Score = Impact × Likelihood
    + Conditional formatting: Đỏ >10, Vàng 5-10, Xanh <5
  - Sheet 2 "Risk List": Danh sách rủi ro chi tiết
    + STT | Rủi ro | Nhóm | Impact | Likelihood | Score | Trạng thái
    + Data từ file nguồn
  - Sheet 3 "Trend": Biểu đồ xu hướng
    + Chart: Line chart 12 tháng
    + Hiển thị trend Increasing/Decreasing/Stable

Bước 4: Format tự động:
  - Header row: Bold, background navy #1B3A5C
  - Number format: #,##0 (cho tiền tệ)
  - Column width auto-fit

Lưu: output/risk_assessment_final.xlsx
```

#### Prompt G: Tạo PowerPoint Presentation
```
Sử dụng skill "bank-audit-report" đã tạo.

Bước 1: Đọc template quarterly_review.md
Bước 2: Tạo PowerPoint mới bằng OfficeCLI (pptx skill):

Slide 1 - Title Slide:
  "BÁO CÁO KIỂM TOÁN NỘI BỘ Q4/2026"
  Subtitle: "Ngân hàng TMCP XYZ"
  [LOGO: top-center, navy background]

Slide 2 - Tổng quan:
  "TỔNG QUAN KẾT QUẢ KINH DOANH"
  - KPI Cards (4 items): DOanh thu, Lợi nhuận, ROE, NPL Ratio
  - So sánh vs Quý trước + YoY

Slide 3 - Phân tích rủi ro:
  "PHÂN TÍCH RỦI RO"
  - Chart: Heat map matrix (5×5)
  - Top 5 rủi ro cao nhất (highlight đỏ)

Slide 4 - Kết quả kiểm toán:
  "KẾT QUẢ KIỂM TOÁN NỘI BỦ"
  - Table: 10 finding chính
  - Severity: Critical / Major / Minor / Observation

Slide 5 - Khuyến nghị:
  "KHUYẾN NGHỊ VÀ HÀNH ĐỘNG"
  - Action items table
  - Responsible person + Deadline
  - Priority: High / Medium / Low

Theme: Navy #1B3A5C, Gold #C9A227, White
Font: Segoe UI Bold

Lưu: output/quarterly_review_Q4_2026.pptx
```

#### Prompt H: Design Dashboard Power BI
```
Sử dụng skill "powerbi-dashboard" đã tạo.

Tạo file Design_PowerBI_Dashboard.md với nội dung chi tiết:

# Dashboard Design Spec: Kiểm toán Nội bộ Q4/2026

## Page 1: Tổng quan Tài chính
- Layout: 4 KPI cards top + 2 charts bottom
- KPI Cards:
  1. Tổng tài sản: #,##0 VND, icon trending-up
  2. ROE: 0.0%, color: green/red theo threshold
  3. NPL Ratio: 0.0%, color: green <2%, red >5%
  4. Capital Adequacy: 0.0%, color: green >10%
- Chart Left: Bar chart "Doanh thu theo quý" (12 bars)
- Chart Right: Line chart "Trend lợi nhuận" (12 points)

## Page 2: Phân tích Rủi ro
- Layout: Heat map center + sidebar details
- Heat Map: 5×5 matrix (Impact × Likelihood)
- Sidebar: Top 10 risks list với drill-through
- Color: Green <5, Yellow 5-10, Red >10

## Page 3: Kết quả Kiểm toán
- Layout: Table center + pie chart right
- Table: Findings list (sortable, filterable)
- Pie Chart: Phân bổ severity (Critical/Major/Minor)
- Drill-through: Click finding → chi tiết

## Page 4: Tuân thủ Pháp luật
- Layout: Checklist center + gauge charts
- Gauge 1: Tỷ lệ tuân thủ (%) - green >90%
- Gauge 2: Thời hạn xử lý (%) - green >80%
- Checklist: Compliance items với status icons

## Data Model:
- Fact: AuditFindings, RiskEvents, Transactions
- Dim: Accounts, Periods, RiskCategories
- Relationships: Star schema

## Measures (DAX):
Total_Revenue = SUM(Transactions[Amount])
Risk_Score = RiskEvents[Impact] * RiskEvents[Likelihood]
Compliance_Rate = COUNT(Findings[Compliant]) / COUNT(Findings[*])

## Color Palette:
Primary: #1B3A5C (Navy)
Accent: #C9A227 (Gold)
Success: #27AE60 (Green)
Warning: #F39C12 (Amber)
Danger: #E74C3C (Red)
Background: #F8F9FA (Light gray)

Lưu: output/Design_PowerBI_Dashboard.md
```

#### Prompt I: Đặt lịch Tự động (Cron)
```
Đặt lịch các task sau trong AionUi:

1. Hàng ngày 8:00 AM:
   "Đọc file data/*.csv mới nhất từ hôm qua,
    Cập nhật báo cáo audit_daily_check.docx,
    Nếu có finding Critical → gửi Telegram alert"

2. Hàng tuần Thứ 6 5:00 PM:
   "Tổng hợp dữ liệu tuần → Tạo file
    risk_weekly_summary.xlsx với chart trend,
    Gửi notification qua Telegram"

3. Hàng tháng 1/7 hàng tháng:
   "Tạo full báo cáo kiểm toán tháng trước:
    - audit_report_monthly.docx
    - risk_assessment_monthly.xlsx
    - quarterly_presentation.pptx (nếu cuối quý)
    Gửi email summary cho audit-committee@bank.com"
```

---

## 4. Cấu trúc Thư mục Project

```
audit-project/
│
├── AGENTS.md                          # Rules chính cho OpenCode
├── opencode.json                      # Config agents + MCP
│
├── .opencode/
│   ├── agents/
│   │   ├── audit-reporter.md          # Agent: Tạo báo cáo audit
│   │   ├── risk-analyst.md            # Agent: Phân tích rủi ro
│   │   ├── compliance-checker.md      # Agent: Kiểm tra tuân thủ
│   │   └── report-scheduler.md        # Agent: Đặt lịch báo cáo
│   │
│   ├── skills/
│   │   ├── bank-audit-report/
│   │   │   └── SKILL.md              # Skill: Báo cáo kiểm toán
│   │   ├── risk-assessment/
│   │   │   └── SKILL.md              # Skill: Đánh giá rủi ro
│   │   ├── financial-review/
│   │   │   └── SKILL.md              # Skill: Đánh giá tài chính
│   │   ├── powerbi-dashboard/
│   │   │   └── SKILL.md              # Skill: Thiết kế dashboard
│   │   ├── office-to-md/
│   │   │   └── SKILL.md              # Skill: Chuyển Office → MD
│   │   └── md-to-office/
│   │       └── SKILL.md              # Skill: Chuyển MD → Office
│   │
│   └── opencode.json                 # Override per-project config
│
├── templates/                         # Templates gốc (đã duyệt)
│   ├── audit_report.docx
│   ├── risk_assessment.xlsx
│   ├── quarterly_review.pptx
│   ├── financial_dash.pbix
│   └── compliance_check.pptx
│
├── templates_md/                      # Templates đã chuyển sang .md
│   ├── audit_report.md
│   ├── risk_assessment.md
│   ├── quarterly_review.md
│   └── financial_dash.md
│
├── data/                              # Dữ liệu đầu vào
│   ├── so_tai_khoan.csv
│   ├── giao_dich_q4.xlsx
│   ├── rui_ro_2026.xlsx
│   └── bao_cao_tai_chinh.csv
│
├── output/                            # Kết quả output
│   ├── audit_report_2026Q4.docx
│   ├── risk_assessment_final.xlsx
│   ├── quarterly_review_Q4_2026.pptx
│   └── Design_PowerBI_Dashboard.md
│
├── design/                            # Design specs
│   ├── Design_BankAudit.md
│   ├── Design_RiskAssessment.md
│   └── Design_FinancialReport.md
│
├── prompts/                           # System prompts
│   ├── audit_prompt.txt
│   ├── risk_prompt.txt
│   └── dashboard_prompt.txt
│
└── memory/                            # Memory files (OpenCode)
    ├── memory.md                      # Trạng thái project
    ├── variables.md                   # Biến cấu hình
    └── progress.md                    # Tiến độ
```

---

## 5. Tổng hợp Video References

| # | Video | Nội dung chính áp dụng |
|---|-------|------------------------|
| 1 | OpenCode + AionUi: Full Desktop AI Agent | Cài đặt AionUi + OpenCode, parallel sessions, remote control, cron jobs |
| 2 | Aion UI Demo: Is This the Ultimate AI Agent Desktop? | Demo built-in agent, assistant ecosystem, file preview |
| 3 | OpenCode Full Tutorial: Free Models, Skills & MCPs | Cấu hình models, tạo skills, MCP servers |
| 4 | OpenCode Tutorial for Beginners: Setup, Agents, Skills & MCP | Step-by-step setup, AGENTS.md, sub-agents |
| 5 | Supercharge OpenCode With 1300+ Free Skills | Community skills hub, extension skills |
| 6 | OpenCode + Graphify: Stop Wasting Tokens | Token optimization, compaction agent |
| 7 | OpenCode UI/UX Skill: Build 100X Better Designs | Design.md pattern, design system rules |
| 8 | OpenCode + Stitch = AMAZING Design | Visual design workflow, screenshot-to-UI |
| 9 | OpenCode + AwesomeDesign-md | Design.md format cho AI-readable design specs |
| 10 | Design.md: How to make your design system work with AI | Design.md best practices, brand tokens |
| 11 | AwesomeDesign-md + OpenCode, Claude |Opensource design system integration |

---

## 6. Bảng So sánh Giải pháp

| Tiêu chí | Truyền thống | AionUi + OpenCode |
|----------|-------------|-------------------|
| Tạo báo cáo Word | Mở Word → Copy template → Paste data thủ công | Chat prompt → Agent tự đọc template + data → Tạo .docx |
| Tạo Excel report | Mở Excel → Format → Viết formula thủ công | Skill xlsx → Agent tạo sheet + chart tự động |
| Tạo PowerPoint | Mở PPT → Design từng slide | Skill pptx → Agent tạo presentation từ outline |
| Dashboard BI | Power BI Desktop → Manual drag-drop | Skill powerbi → Tạo spec .md + design measures |
| Đặt lịch | Nhớ task + Calendar | Cron prompt → AionUi chạy tự động |
| Phân tích rủi ro | Excel manual calculation | Agent phân tích + tạo heat map |
| Kiểm tra tuân thủ | Đọc từng checklist | Agent scan data → Auto-check compliance |
| Remote control | Phải ngồi máy | Telegram bot → Chạy từ điện thoại |
| Version history | Save-as nhiều lần | Git tự động snapshot + rollback |
| Chi phí | License phần mềm | Free (chỉ trả API tokens) |

---

## 7. Bắt đầu Nhanh (Quick Start)

```bash
# BƯỚC 1: Cài đặt
brew install opencode          # hoặc: npm i -g opencode-ai@latest
brew install --cask aion-ui    # hoặc: tải từ github.com/iOfficeAI/AionUi/releases

# BƯỚC 2: Khởi động AionUi, chọn OpenCode Agent
# Nhập API key (Anthropic/OpenAI/Google) trong Settings

# BƯỚC 3: Clone hoặc tạo project
mkdir audit-project && cd audit-project
opencode    # Khởi động OpenCode trong terminal
/init       # Tạo AGENTS.md

# BƯỚC 4: Tạo cấu trúc thư mục
mkdir -p templates data output templates_md design prompts memory
mkdir -p .opencode/agents .opencode/skills

# BƯỚC 5: Copy templates vào thư mục templates/

# BƯỚC 6: Bắt đầu chat trong AionUi
# → Thực hiện Prompt A, B, C, D ở trên để chuyển templates → .md
# → Thực hiện Prompt E, F, G, H để tạo báo cáo mới
# → Thực hiện Prompt I để đặt lịch tự động
```

---

## 8. Best Practices

1. **Bảo mật**: Dùng local models (Ollama) cho dữ liệu nhạy cảm ngân hàng
2. **Version Control**: Luôn commit AGENTS.md + templates/ + skills/ lên Git
3. **Template-first**: Luôn chuyển template sang .md trước khi dùng để Agent hiểu rõ cấu trúc
4. **Parallel execution**: Sử dụng AionUi parallel tabs để tạo nhiều báo cáo cùng lúc
5. **Git rollback**: AionUi tự động snapshot → dùng rollback button nếu kết quả sai
6. **Skill modularity**: Mỗi skill = 1 folder, 1 SKILL.md, 1 mục đích rõ ràng
7. **AGENTS.md rules**: Viết rõ quy định domain (ISO 19011, Thông tư 05/2017) trong AGENTS.md
8. **Cron scheduling**: Đặt lịch qua plain English trong chat, AionUi tự tạo cron job
9. **Remote access**: Kết nối Telegram bot để chạy từ điện thoại khi vắng mặt
10. **Cost control**: Dùng cheap model (Gemini Flash) cho compaction, expensive model (Claude) cho analysis

---

*Tài liệu này được tạo dựa trên phân tích 11 video tutorials về AionUi + OpenCode và documentation chính thức.*
