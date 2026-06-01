# Skill: open-design

## Mô tả
Tạo thiết kế (prototype, deck, dashboard) qua Open Design platform.
Open Design là open-source Claude Design alternative (nexu-io, 56.8k⭐).

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
- saas-landing: SaaS landing page
- weekly-update: weekly newsletter template

## Design systems phổ biến (150+)
- linear: Linear app style (modern minimal)
- stripe: Stripe brand (tech utility)
- vercel: Vercel style (developer focused)
- notion: Notion style (editorial)
- apple: Apple HIG (clean, rounded)
- anthropic: Anthropic Claude style
- cursor: Cursor IDE style

## Cách sử dụng

### Tạo prototype
opendesign_generate_prototype(
    name="Sales Dashboard Q2",
    skill_id="dashboard",
    design_system_id="stripe",
    brief="Dashboard cho doanh số theo tuần, top sản phẩm, pipeline"
)

### Tạo presentation deck
opendesign_generate_deck(
    name="Bao cao Q2",
    brief="Báo cáo tài chính quý 2 cho ban lãnh đạo",
    deck_style="guizang-ppt",
    design_system_id="linear"
)

### Xuất file
opendesign_export_artifact(
    project_id="...",
    format="html",
    output_path="C:/output/dashboard.html"
)

### Liệt kê skills
opendesign_list_skills()
→ 137 skills có sẵn

### Kiểm tra trạng thái
opendesign_get_project_status(project_id="...")
→ project + artifact metadata

### Áp dụng design system
opendesign_apply_design_system(
    project_id="...",
    design_system_id="notion"
)

### Danh sách projects
opendesign_list_projects()
→ Tất cả projects + trạng thái
