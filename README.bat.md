# Tạo file start_jupyter_lab.bat:

Tôi muốn viết 1 file .bat để chạy trên windows 11 truy cập jupyter lab theo bước khởi động biến môi trường open-webui
Để tạo một file .bat giúp bạn khởi động Jupyter Lab trên Windows 11 với biến môi trường OPEN_WEBUI, bạn có thể làm theo các bước sau đây:

Mở Notepad hoặc bất kỳ trình soạn thảo văn bản nào. Sao chép và dán mã sau vào Notepad:
```
@echo off
set OPEN_WEBUI=True
jupyter lab
```

**Giải thích mã:**
- @echo off: Tắt hiển thị các lệnh trong cửa sổ Command Prompt.
- set OPEN_WEBUI=True: Thiết lập biến môi trường OPEN_WEBUI với giá trị True.
- jupyter lab: Lệnh để khởi động Jupyter Lab.

**Lưu file:**
Chọn "File" > "Save As".
- Đặt tên file là start_jupyter_lab.bat.
- Chọn "All Files" trong phần "Save as type".
- Lưu file ở một vị trí mà bạn dễ dàng truy cập (ví dụ: Desktop). 
- Chạy file .bat:
- Nhấp đúp vào file start_jupyter_lab.bat để chạy. Cửa sổ Command Prompt sẽ mở ra và Jupyter Lab sẽ khởi động.

**Lưu ý:**
- Đảm bảo rằng bạn đã cài đặt Jupyter Lab và đã thêm nó vào PATH trong môi trường hệ thống của bạn để lệnh jupyter lab có thể được nhận diện.
- Nếu bạn có thêm câu hỏi hoặc cần hỗ trợ thêm, hãy cho tôi biết!
