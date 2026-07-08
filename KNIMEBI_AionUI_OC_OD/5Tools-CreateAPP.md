
## Kịch bản 1: 🔵 Không cần lập trình — Sử dụng Trợ lý AI của Agent có sẵn Kỹ năng:
***(No-Code - Utilizing the AI Agent Assistant with Available Skills)***

### Phân loại và Kịch bản: 

#### Vấn đề: 
Chủ động lấy được các dữ liệu dạng Văn bản, tài liệu mẫu, Các đoạn Video, audio có nguồn gốc, biết một vài định dạng dữ liệu cụ thể như: Mp3, midi, aud, media track thường dùng để lưu trữ và để nghe/xem lại tư liệu. nhưng nếu phải tổng hợp, phân tích chuyển đổi sang các dạng dữ liệu thông tin phát sinh hàng ngày (ghi âm, ghi hình cuộc họp và phải viết báo cáo tổng hợp hoặc chi tiết thì rất khó hoặc không biết đề xuất dùng chúng cùng lúc và xử lý định dạng Dữ liệu số đó có thể phân tích như thế nào để đạt mục tiêu?

#### Kịch bản 1.1.: 
>>>tôi cần viết đoạn code html5 sao cho dạng URL https://yourdomain.vn/readdocx.html?read=Vị_Trí_Huyệt_Đạo_Trên_Cơ_Thể.docx toàn bộ đoạn code html, js, css giúp mở xem read và modify file Dcox online mà không cần download về máy cá nhân. Lưu ý: đoạn code trên tôi đang chạy thử html5 trên localhost:3003 thì thư mục /files chứa file docx, doc. Ví dụ:http://localhost:3003/readdoc.html?read=Vị_Trí_Huyệt_Đạo_Trên_Cơ_Thể.docx như cách này thì sẽ bị báo lỗi An error occurred: We're sorry, but for some reason we can't open this for you. Learn more. Do vậy, hãy sửa lại code html5 cho phép dùng cả localhost và port khác 80 , 443. và cho thao tác đổi từ Read sang Edit được.

---> Gợi ý: hãy tạo thư mục dự án trong Documents\Tools và chọn Opencode, chọn Permission Plan Mode để phân tích dữ liệu trước.

#### Kịch bản 1.2.: 
>>>Tôi gặp vấn đề mở file excel để view, sửa, thay đổi dữ liệu, vẽ lại biểu đồ, chọn và sửa lại công thức tính của các files excel. Trong khi đó hệ thống windows remote không được cài MS Office 365, chỉ có dùng được Google Sheet URL, hoặc https://excel.cloud.microsoft/ nhưng lại phải có Accounts của 2 hãng này mà Đơn vị Doanh nghiệp không thuê các dịch vụ trên.
Hãy viết cho tôi 1 trang chuẩn html, js, css để có thể mở hoặc tạo mới các files Excel đầy đủ các tính năng chạy Localhost hoặc trên web html và lưu tại thư mục dự án Documents\Tools\excel-local.html

---> Gợi ý: hãy tạo thư mục dự án trong Documents\Tools và chọn Opencode, chọn Permission Plan Mode để phân tích dữ liệu trước.

#### Kịch bản 1.3.:
>>>Tôi cần viết tool xem soạn sửa preview file markdown .md: "Tôi gặp vấn đề mở file md để mở xem, sửa, thay đổi nội dung, vẽ lại biểu đồ chart, mermaid, graphic ascii của các files md. Trong khi đó hệ thống windows remote không được cho truy cập https://github.com và cũng không có Account github. Hãy viết cho tôi 1 trang chuẩn html, js, css để có thể mở, tạo mới, sửa chữa, preview và các chức năng xử lý files md chạy Localhost hoặc trên web html và lưu tại thư mục dự án Documents\Tools\markdown-local.html"

---> Gợi ý: hãy tạo thư mục dự án trong Documents\Tools và chọn Opencode, chọn Permission Plan Mode để phân tích dữ liệu trước.

## Kịch bản 2: 🟢 Không cần lập trình — Lời nhắc cho Trình tạo bảng điều khiển:
***(No-Code — Prompt to Dashboard Creator)***

### Phân loại và Kịch bản: 

#### Vấn đề:  
Chủ động lấy được các dữ liệu dạng nhật ký hệ thống SysLOG, biết một vài files Log thường dùng để phân tích, nhưng SysLOG quá nhiều dữ liệu thông tin phát sinh hàng ngày
và không biết đề xuất dùng chúng cùng lúc và xử lý định dạng Dữ liệu Log có thể phân tích như thế nào để đạt mục tiêu?

#### Kịch bản 2.1.: 
>>>Tôi có các files SYSLOG của ESXi Log lưu ở thư mục D:\BaiTap5\Nhom2\esxi_log\*.log 
Hãy phân tích đọc các files Log và để có thể tạo ra hệ thống Documents\Tools\ESXi-LOG_Dashboard.html sao cho có thể thiết kế ra được hệ thống Monitoring Dashboard phân tích báo cáo các hành vi, các dấu hiệu insight LOG vận hành có nguy cơ mất ổn định, sự cố tiềm tàng, Pain point bảo mật Admin, bottleneck, Xác định các chỉ số vận hành( CPU sizing, RAM Capacity usage, Storage Capacity and IOPS, Latency, Throughtput, bandwidth), Các security, VCE lỗ hổng, Critical khẩn cấp. Tuổi mật khẩu root/admin local/administrator, Các truy cập tài khoản root kém an toàn, lỗi truy cập/đăng nhập. 
Đồng thời viết thành file tài liệu Documents\Tools\Esxi-LOG_readme_v2.md (Để thiết kế một hệ thống Monitoring Dashboard hiệu quả cho VMware ESXi 8.0 Syslog, bạn cần kết hợp chặt chẽ giữa Tư duy Dữ liệu (Data Thinking) để xử lý cấu trúc log và Tư duy Thiết kế (Design Thinking) để tối ưu hóa trải nghiệm người dùng vận hành).

---> Gợi ý: hãy tạo thư mục dự án trong Documents\Tools và chọn Opencode, chọn Permission Plan Mode để phân tích dữ liệu trước.


#### Kịch bản 2.2.: 

##### Tóm tắt Vấn đề:  
Biết về phần mềm RvTools 4.7.1 là công cụ Export ra Excel files các thông tin căn bản đang vận hành của máy chủ hệ thống, các thông tin dạng nhật ký thường dùng để phân tích, nhưng quá nhiều Sheetname và có nhiều dữ liệu thông tin phát sinh hàng ngày không biết đề xuất dùng chúng cùng lúc và xử lý định dạng Dữ liệu Excel có thể phân tích như thế nào để đạt mục tiêu (ví dụ: làm thế nào có 1 Báo cáo vận hành thống nhất và cập nhật liên tục)?

>>>Tôi có các file excel được export từ phần mềm RvTools 4.7 của DELL, và tài liệu hướng dẫn giới thiệu: https://github.com/PhDLeToanThang/automation/blob/main/rvtools/rvtools4.7.pdf
- Ngoài ra, mỗi lần chạy RvTools kết nối cụm máy chủ vCenter Appliance 8 hoặc kết nối riêng lẻ từng ESXi host 7.0 /8.0 tôi đều
export ra các file Excel và lưu vào 1 thư mục dự án các báo cáo này ở thư mục: D:\BaiTap5\Nhom2.2\ATCBI\ATC_RVTools_export_all_2026-06-02_12.47.53.xlsx
các file tôi có thay tên như: ATC_RVTools_export_all_2026-06-02_12.47.53.xlsx
Mỗi file excel có tới 27 sheets.
- Hãy phân tích lại cấu trúc các trường thông tin, kiểu trường phù hợp có trong 27 sheets và nội dung dữ liệu để có thể thiết kế sang 1 dữ liệu sqlite3 db tại máy chạy hosting local, và dùng html,js,css để thiết kế web form kiểu dạng Full-Stack vừa có front-end cho admin role vừa có backend chứa database, vừa có api web thiết kế UI/UX:
- Tạo 1 tab menu "Input data" kiểu upload các files excel trên theo kiểu quy trình ETL và tự động cho các dữ liệu đó converter vào sqlite3 theo Databases và các tables tương ứng với sheetname có trong excel
(Lưu ý: tránh bị nhập trùng lại các file excel đã uploaded, bằng cách đánh dấu thêm vào 1 bảng history và sẽ bỏ qua với các files excel đã nhập, thông báo sau khi có kết quả hoàn thành).
- Tiếp theo, tạo cho tôi 1 tab menu "Process data" hiển thị grid các dữ liệu của 27 sheets cho phép cộng gộp các dòng dữ liệu thêm trường dữ liệu ngày tháng năm, giờ phút giây cập nhật (uploaded), Dòng cuối của grid sẽ có thêm 1 dòng tổng trung bình của các giá trị số nguyên có trong các cột.
- Tiếp theo, tạo cho tôi 1 tab menu "Metric Data" là bảng tính toán gồm:
+ Lấy dữ liệu từ Table: vHost:  CPU Usage %/host (tổng số hosts) , usage vCPU/VMs (tổng số VMs), Average % , VMs per core.  
    + vẽ thêm biểu đồ lines cấc thời điểm upload có thay đổi.
+ Lấy dữ liệu từ Table: vHost:  Memory Usage %/host (tổng số hosts) , VM used memory, Average %
+ vẽ thêm biểu đồ lines cấc thời điểm upload có thay đổi.
+ Lấy dữ liệu từ Table: vDatastore: Tên từng Name Storage và số VMs, Capacity GB, Provisioned (Số đã cấp) GB, Số đang dùng GB, Free %.
+ vẽ thêm biểu đồ lines cấc thời điểm upload có thay đổi.
+ Lấy dữ liệu từ table: vSC_VMK: Tên Port Group, device, Host, ipv4, subnet mark, gateway , mtu
+ Lấy dữ liệu từ table: vCluster: NumHosts, TotalCpu, NumCpuCores, NumCpuThreads, Effective Cpu, TotalMemory, Effective Memory
+ vẽ thêm biểu đồ lines cấc thời điểm upload có thay đổi.
- Tiếp theo, tạo cho tôi 1 tab menu "KPI performance" là bảng tính toán gồm:
+  Lấy dữ liệu từ Table: vCPU,  tính Use vCpu < 75% (ổn định: chữ to đâm mầu xanh green, 87.5% >= mầu cam > 75%, mầu đỏ <= 93%)
+ Lấy dữ liệu từ Table: vMemory, tính Use Consumed < 75% (ổn định: chữ to đâm mầu xanh green, 87.5% >= mầu cam > 75%, mầu đỏ <= 93%)
+ Lấy dữ liệu từ table: vPartition: tính VD và từng vùng vPartition của từng VM với Capacity MiB, Consumed MiB, Free MiB, Free %
+ vẽ thêm biểu đồ lines các thời điểm upload có thay đổi (ổn định: chữ to đâm mầu xanh green <=80%, 90% >= mầu cam > 80%, mầu đỏ <= 97%)
- Tiếp theo, tạo cho tôi 1 tab menu "ORKI Risk Compliance" là bảng tính toán gồm:
    + Lấy dữ liệu từ Table: vHealth.
+ Lấy dữ liệu từ Table: vCD.
+ Lấy dữ liệu từ Table: vNetwork.
+ Lấy dữ liệu từ Table: vTools.
+ Lấy dữ liệu từ table: vUSB.
Sau khi tạo code Html5 trên tôi sẽ dùng chạy mô phỏng, sau đó hãy viết thành file SKILL.md các bước của dự án để tôi có thể đưa sang Opencode local để chạy Full-stack next.js, node.js, python 3.11, prisma, sqlite3 db.

---> Gợi ý: hãy tạo thư mục dự án trong Documents\Tools và chọn Opencode, chọn Permission Plan Mode để phân tích dữ liệu trước.

## Kịch bản 3: 🟡 OpenCode Sinh Python Tool — Web App Đơn Giản



## Kịch bản 4: 🟠 MCP Server — Mở Rộng AionUI Bằng Python


## Kịch bản 5: 🟣 Cron + Python — Tự Động Hóa Xử Lý Hàng Loạt
