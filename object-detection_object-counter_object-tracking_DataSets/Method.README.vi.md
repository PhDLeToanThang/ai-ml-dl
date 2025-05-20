# Model YOLO của Ul

>> Vẽ sơ đồ 2 phương án giúp tôi theo nội dung sau:

Phương án 1 (A):
1. Thuê dịch vụ Camera IP loại có thể ghi hình trên Cloud Storage.
2. Thuê dịch vụ lưu trữ Video MP4 trên Cloud Storage theo dung lượng Web HTTPS (Minio / S3 storage).
3. Thuê dịch vụ AI Object Detection + Object Counter + Object Tracking Line và xuất ra báo cáo HTML5/Excel/CSV/ Power BI Publish.

Phương án 2 (B):
1. Có thể gặp phải dạng dùng Camera bình thường nhà dân và ủy quyền cho 1 nhân viên có thể đi tới copy vào Hard disk
2. Sau đó có thể dùng Hard disk đó copy lên S3c Object Storage do CTy thuê hoặc đặt hosting trên VMs của ISP
3. Ở dưới Local của AT.COM có con Laptop + GPU và đoạn python AI (Pycharm + jupyter lab/notebook / python jupyterhub hosting) để gọi các file video mp4 theo link của S3c đã public URL cho Admin có thể get/read URL files mp4 đó) và đếm bằng model YOLO là sẽ ra kết quả cần và đẩy về báo cáo qua Email / xuất file Excel có định dạng thông tin cột cần báo cáo / Đẩy vào Power BI Report Server của AT.COM và share theo quyền AD để xem.


>>https://poe.com/Drawio

### This draw.io diagram includes:



### Save file or change extention file .xml > .drawio
- Dùng Drawio mở file .drawio và chỉnh sửa

![image](https://github.com/user-attachments/assets/ff50cd66-593e-4832-aba4-73eb49c4c963)

- Sau đó Export dưới dạng XML:
  
![image](https://github.com/user-attachments/assets/3ea7e319-d34d-4679-941f-9a4c16c0cc01)

- Mở nội dung XML có:

![image](https://github.com/user-attachments/assets/c7b3b68e-73c7-4f37-9fd3-e070a44c68f5)

- Cuối cùng đẩy file XML lên github:

![image](https://github.com/user-attachments/assets/26f6f3ca-5cda-447a-ac2c-125896b3dc3e)

- Lấy URL Link của file XML trên raw.github

>> trên github.com tôi có thể đưa hình ảnh hiển thị của drawio dạng file xml?
bạn có thể đưa tệp Draw.io (.xml) lên GitHub và vẫn hiển thị hình ảnh trực tiếp bằng cách sử dụng Draw.io GitHub Integration hoặc Markdown hỗ trợ Draw.io.

Cách tải lên tệp Draw.io (.xml) lên GitHub

1️⃣ Tải lên tệp .drawio hoặc .xml

Bạn có thể tải lên tệp .xml trên GitHub như một tệp thông thường.

Nếu muốn chỉnh sửa trực tiếp trên GitHub, hãy đổi định dạng thành .drawio để tương thích với Diagrams.net (Draw.io).

2️⃣ Hiển thị hình ảnh Draw.io trên GitHub

Bạn có thể xuất hình ảnh từ Draw.io dưới dạng .png hoặc .svg rồi chèn vào README bằng Markdown:

![Diagram Method_Object-Conter_Object-TrackingLine](https://raw.githubusercontent.com/PhDLeToanThang/ai-ml-dl/refs/heads/main/object-detection_object-counter_object-tracking_DataSets/MethodAB_CameraIP_Object-Detection_Object-Conter_Object-TrackingLine.drawio.svg)

3️⃣ Sử dụng Draw.io trực tiếp trên GitHub

Draw.io GitHub Plugin cho phép mở và chỉnh sửa .drawio ngay trong trình duyệt.

Khi mở .drawio trên GitHub, bạn có thể chọn Edit using Draw.io để chỉnh sửa trực tiếp.
