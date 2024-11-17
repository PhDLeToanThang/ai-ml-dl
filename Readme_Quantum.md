# Quantum converter from AI 

## Cài đặt Quantum từ Python 3.11:
Hướng dẫn cài đặt Python 3.11 trên Windows 11:
> **Bước 0. Tải và cài Python3.11 trên windows x64**
- Tạo thư mục cd c:\python311
- Tải bộ cài python3.11 và cài vào thư mục c:\python311
- Tiếp theo dùng cmd /admin gõ lệnh cd c:\python311 và
- python.exe -m pip install --upgrade pip

> **Bước 1: Tạo môi trường ảo mới**
Bạn có thể sử dụng venv để tạo một môi trường ảo mới. Chạy lệnh sau trong terminal:

Trên macOS/Linux:
```
python3 -m venv quantum
```

Trên Windows:
```
python -m venv quantum
```
> **Bước 2: Chạy môi trường ảo mới:**
Trên macOS/Linux:
```
source quantum/bin/activate
```

Trên Windows:
```
quantum\Scripts\activate
```

> **Bước 3: Cài đặt Qiskit:**
Sau khi môi trường đã được kích hoạt, bạn có thể cài đặt Qiskit bằng lệnh sau:
```
pip install "qiskit>=1"
```
Nếu bạn cần cài đặt thêm các gói khác như jupyterlab, pandas, hoặc matplotlib, bạn có thể làm như sau:
```
pip install "qiskit>=1" jupyterlab pandas matplotlib
```
> **Bước 4: Kiểm tra cài đặt:**
Sau khi cài đặt xong, bạn có thể kiểm tra xem Qiskit có được cài đặt thành công hay không bằng cách mở Python và chạy lệnh sau:

python

```
import qiskit
print(qiskit.__version__)
```
Nếu bạn không thấy lỗi nào, thì việc cài đặt đã thành công.

> **Lưu ý:**
Đảm bảo rằng không có bất kỳ gói nào phụ thuộc vào qiskit-terra trong môi trường này, vì chúng không tương thích với Qiskit 1.0.
Nếu bạn vẫn cần sử dụng gói cũ hơn, bạn nên tạo một môi trường ảo riêng biệt cho chúng.
