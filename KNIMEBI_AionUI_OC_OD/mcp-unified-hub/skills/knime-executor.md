# Skill: knime-executor

## Mô tả
Chạy và quản lý KNIME workflows thông qua MCP integration hub.

## Yêu cầu
- MCP server `integration-hub` đã cấu hình
- KNIME Analytics Platform 5.9+ có Batch Executor extension
- KNIME workspace path đúng trong cấu hình

## Cách sử dụng

### Chạy workflow
knime_execute_workflow(
    workflow_dir="etl-sales",
    variables={"year": "2026", "quarter": "Q2"}
)
→ Exit code 0 = thành công, 4 = lỗi execution

### Liệt kê workflows có sẵn
knime_list_workflows()
→ Danh sách tất cả workflows trong workspace

### Đọc kết quả đầu ra
knime_read_output_table(
    output_path="output/sales-summary.csv",
    max_rows=50
)
→ Dữ liệu CSV dạng list of dicts

### Kiểm tra workflow tồn tại
knime_get_workflow_status(workflow_dir="etl-sales")
→ {exists: true/false, path, name}

## Exit codes
- 0: Thành công
- 2: Sai tham số dòng lệnh
- 3: Lỗi load workflow
- 4: Lỗi execution
