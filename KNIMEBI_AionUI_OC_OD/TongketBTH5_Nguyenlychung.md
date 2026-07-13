# Tổng Kết Bài Thực Hành 5

## Mô hình tổng quan: AionUI + OpenCode + MCP → Tự động hóa BI & Báo cáo

---

## GIAI ĐOẠN 1: Xây dựng Kiến thức chốt (.md)

| Bước | Hoạt động | Ghi chú |
|------|-----------|---------|
| **1** | **Thu thập tài liệu tham khảo** | YouTube, blog, Reddit, bài báo về AI + Power BI / MCP |
| **2** | **AionUI + OC phân tích & tổng hợp** | Học nội dung, viết tóm tắt ý kiến diễn giả → xuất file `.md` |
| **3** | **Con người Review & Kiểm chứng** | Kiểm tra lỗi thời, phiên bản cũ, plugin không tương thích |
| **4** | **Yêu cầu AionUI + OC viết lại** | Sửa đổi, bổ sung thành gói giải pháp mới. Yêu cầu OC diễn tả cách làm riêng |
| **5** | **Xuất `.md` lần 2 → Review bằng Viewmd.html** | Soạn, sửa, preview cùng lúc → file `.md` chốt làm tư duy thiết kế |
| **6** | **Khóa file `.md` làm Kiến thức chốt** | Các `.md` này là đầu vào cho mọi giai đoạn tiếp theo |

---

## GIAI ĐOẠN 2: Mở rộng → Học mẫu Văn bản ngành

| Bước | Hoạt động | Ghi chú |
|------|-----------|---------|
| **7** | **Thu thập mẫu văn bản ngành** | `.docx`, `.xlsx`, `.pptx`, `.pdf` (có ảnh, logo, header, footer) |
| **8** | **AionUI + OC học & thiết kế** | Phân tích mẫu → viết file `[Vanban]-Design_[v1].md` |
| **9** | **Tự động hóa điền dữ liệu** | OCR → điền vào file mẫu theo design `.md` đã có |

---

## GIAI ĐOẠN 3: Kết nối MCP → Ứng dụng BI Desktop

| Bước | Hoạt động | Ghi chú |
|------|-----------|---------|
| **10** | **Xác định ứng dụng nguồn** | Excel, Power BI Desktop, KNIME Analytics Desktop |
| **11** | **Yêu cầu OC thiết kế MCP Local** | OC nghiên cứu → sửa file `mcp.json` cấu hình chuẩn |
| **12** | **Khởi động MCP Service** | Kiểm tra chạy thông → test kết nối |
| **13** | **Đẩy dữ liệu & Design sang ứng dụng** | Từ `.md` kiến thức → MCP → Excel / PBI / KNIME hiển thị kết quả |

---

## Lưu đồ tổng hợp

```
┌─────────────────────────────────────────────────────────────┐
│  GIAI ĐOẠN 1: XÂY DỰNG KIẾN THỨC CHỐT                       │
│                                                             │
│  [Tham khảo] ──→ [OC phân tích] ──→ [file.md v1]            │
│                                         │                   │
│                                    [Con người Review]       │
│                                         │                   │
│                              [OC viết lại + OC diễn tả]     │
│                                         │                   │
│                                    [file.md v2]             │
│                                         │                   │
│           [markdown-local.html/ Viewmd.html preview]        │
│                                         │                   │
│                              ═══ KHÓA .md ═══               │
└─────────────────────────┬───────────────────────────────────┘
                          │
          ┌───────────────┴───────────────┐
          ▼                               ▼
┌─────────────────────┐     ┌──────────────────────────────────┐
│ GIAI ĐOẠN 2         │     │ GIAI ĐOẠN 3                      │
│ Học mẫu Văn bản     │     │ Kết nối MCP → Ứng dụng BI        │
│                     │     │                                  │
│ [Mẫu .docx/.xlsx]   │     │ [Xác định ứng dụng]              │
│       │             │     │        │                         │
│ [OC thiết kế]       │     │ [OC sửa mcp.json]                │
│       │             │     │        │                         │
│ [Design_v1.md]      │     │ [Test MCP Service]               │
│       │             │     │        │                         │
│ [OCR → Điền data]   │     │ [Đẩy data + Design → App]        │
└─────────┬───────────┘     └───────────────┬──────────────────┘
          │                                 │
          └─────────────┬───────────────────┘
                        ▼
         ┌──────────────────────────────┐
         │   KẾT QUẢ HIỂN THỊ           │
         │                              │
         │  • Excel SW  (điền data)     │
         │  • Power BI   (Dashboard)    │
         │  • KNIME      (ETL/Flow)     │
         │  • Báo cáo Word/PPT          │
         └──────────────────────────────┘
```

---

## Nguyên tắc cốt lõi

1. **Con người Review** trước khi OC làm bước tiếp — không tự động 100%
2. **`.md` là kiến thức chốt** — mọi bước sau đều tham chiếu lại
3. **MCP là cầu nối** — chỉ cấu hình đúng `mcp.json` là OC kết nối được Excel/PBI/KNIME
4. **OC chạy local** — không tốn Token Fee, bảo mật dữ liệu
5. **Prompt Chain** — mỗi bước là 1 lệnh rõ ràng, OC thực hiện tuần tự
