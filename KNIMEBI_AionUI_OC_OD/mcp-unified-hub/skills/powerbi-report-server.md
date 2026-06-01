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

### Xem data sources
powerbirs_list_datasources()
→ Danh sách data sources + connection strings

### Xem refresh plans
powerbirs_list_refresh_plans(report_id="...")
→ Lịch sử và trạng thái refresh

### Tạo folder mới
powerbirs_create_folder(
    name="Bao cao 2026",
    description="Báo cáo định kỳ năm 2026"
)

### Xem lịch sử refresh
powerbirs_get_refresh_history(plan_id="...")
→ Các lần chạy trước + thời gian + kết quả
