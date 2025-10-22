### Phần tải, cài, cấu hình Open-Webui làm GUI WEB AI:

>>> Hãy phân tích chi tiết và hướng dẫn từng bước để tôi có thể tải, cài , cấu hình Open WebUI phiên bản mới nhất cài trên windows 10 / 11 pro licensed (ipv4 192.168.1.39) và có thể cho phép gọi Model AIs từ Ollama Agent và Genimi google và từ LM Studio Desktop sau đó có thể cho phép người dùng thêm tài khoản truy cập qua web browser từ máy khác (192.168.1.22) tới trong mạng LAN, VPN.

---

Yêu cầu của bạn rất chi tiết và bao gồm nhiều thành phần tích hợp. Đây là một hướng dẫn đầy đủ, từng bước để bạn có thể cài đặt và cấu hình Open WebUI trên Windows 10/11 Pro, kết nối với nhiều nguồn model AI khác nhau và cho phép truy cập từ máy khác trong mạng LAN.

Tôi sẽ chia hướng dẫn thành các bước rõ ràng để bạn dễ dàng theo dõi.

### **Tổng quan kiến trúc**

*   **Máy chủ (Host):** `192.168.1.39` (Windows 10/11 Pro)
    *   Chạy **Docker** để chứa Open WebUI.
    *   Chạy **Ollama** như một service nền.
    *   Chạy **LM Studio** như một ứng dụng desktop (khi cần).
    *   Open WebUI sẽ được cấu hình để "gọi" đến các dịch vụ này.
*   **Máy khách (Client):** `192.168.1.22`
    *   Truy cập Open WebUI qua trình duyệt web bằng địa chỉ `http://192.168.1.39:3000`.
*   **Ngoại vi:**
    *   **Google Gemini API:** Open WebUI sẽ gọi trực tiếp ra internet đến API của Google.

---

### **Bước 1: Chuẩn bị các phần mềm cần thiết trên máy chủ (192.168.1.39)**

Trước khi cài đặt Open WebUI, bạn cần cài đặt các nền tảng và phần mềm phụ trợ.

#### 1.1. Cài đặt Git
Git cần thiết để clone mã nguồn của Open WebUI (nếu bạn cài đặt bằng Python) hoặc để tương tác với các repository.
1.  Tải Git từ trang chủ: [https://git-scm.com/download/win](https://git-scm.com/download/win)
2.  Chạy file cài đặt và giữ nguyên các cài đặt mặc định (Next -> Next...).
3.  Kiểm tra cài đặt: Mở Command Prompt (cmd) hoặc PowerShell và gõ:
    ```bash
    git --version
    ```

#### 1.2. Cài đặt Docker Desktop (Khuyến khích nhất)
Docker là cách đơn giản và ổn định nhất để chạy Open WebUI, giúp tránh các vấn đề về phụ thuộc Python và cách ly môi trường hoàn hảo.

1.  Tải Docker Desktop for Windows từ trang chủ: [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)
2.  Chạy file cài đặt và làm theo hướng dẫn. Máy sẽ cần khởi động lại sau khi cài đặt xong.
3.  Sau khi khởi động, Docker Desktop sẽ tự động khởi động. Bạn sẽ thấy biểu tượng của nó trong khay hệ thống.
4.  Kiểm tra cài đặt: Mở Command Prompt (cmd) hoặc PowerShell và gõ:
    ```bash
    docker --version
    ```

#### 1.3. Cài đặt và cấu hình Ollama
Ollama sẽ chạy như một service nền trên máy của bạn, cung cấp các model LLM cục bộ.

1.  Tải Ollama cho Windows từ trang chủ: [https://ollama.com/download](https://ollama.com/download)
2.  Cài đặt như một chương trình Windows bình thường.
3.  Sau khi cài đặt, Ollama sẽ tự động chạy dưới nền. Để kiểm tra, mở Command Prompt và gõ:
    ```bash
    ollama --version
    ```
4.  Tải một model về để dùng, ví dụ `llama3`:
    ```bash
    ollama pull llama3
    ```
5.  **Quan trọng:** Mặc định, Ollama chỉ lắng nghe trên `127.0.0.1` (localhost). Để Docker có thể truy cập, chúng ta sẽ dùng một mẹo nhỏ trong lệnh `docker run` sau này, nên bạn **không cần** thay đổi cấu hình Ollama.

#### 1.4. Cài đặt LM Studio
LM Studio là một ứng dụng desktop giúp bạn dễ dàng tải và chạy các model.

1.  Tải LM Studio từ trang chủ: [https://lmstudio.ai/](https://lmstudio.ai/)
2.  Cài đặt và mở ứng dụng.
3.  Trong tab **Home** (biểu tượng nhà), tìm và tải một model bạn muốn dùng (ví dụ: một model nhỏ gọn như `Phi-3-mini-4k-instruct-gguf`).
4.  Trong tab **Chat** (biểu tượng trò chuyện), tải model bạn vừa tải về.
5.  Ở góc dưới bên phải, chuyển sang tab **Server**. Bật server lên. Mặc định nó sẽ chạy trên địa chỉ `http://localhost:1234`. **Giữ nguyên cài đặt này**.

#### 1.5. Lấy API Key cho Google Gemini
1.  Truy cập: [https://aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)
2.  Đăng nhập bằng tài khoản Google của bạn.
3.  Nhấn nút **"Create API Key"** và sao chép key đó lại. Cất giữ key này cẩn thận, nó giống như mật khẩu của bạn.

---

### **Bước 2: Cài đặt và cấu hình Open WebUI bằng Docker**

Đây là bước cốt lõi. Chúng ta sẽ dùng một lệnh `docker run` duy nhất để tải và khởi động Open WebUI với tất cả các cấu hình cần thiết.

1.  Mở **Command Prompt** hoặc **PowerShell** trên máy chủ `192.168.1.39`.

2.  Dán và chạy lệnh sau:

    ```bash
    docker run -d -p 0.0.0.0:3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
    ```

**Phân tích chi tiết lệnh trên:**

*   `docker run -d`: Chạy container ở chế độ nền (detached).
*   `-p 0.0.0.0:3000:8080`: Đây là phần **quan trọng nhất cho truy cập mạng**.
    *   Nó ánh xạ cổng `8080` bên trong container ra cổng `3000` trên máy host.
    *   `0.0.0.0` có nghĩa là lắng nghe trên **tất cả các giao diện mạng** của máy host, không chỉ `localhost`. Điều này cho phép các máy khác trong LAN (như `192.168.1.22`) có thể truy cập.
*   `--add-host=host.docker.internal:host-gateway`: Đây là một "phép màu" của Docker. Nó cho phép container bên trong có thể gọi đến các dịch vụ đang chạy trên máy host (máy tính của bạn) bằng địa chỉ `host.docker.internal`. Chúng ta sẽ dùng địa chỉ này để kết nối với Ollama và LM Studio.
*   `-v open-webui:/app/backend/data`: Tạo một volume tên là `open-webui` để lưu trữ dữ liệu của Open WebUI (người dùng, cài đặt, lịch sử chat). Dữ liệu này sẽ không bị mất khi bạn xóa và chạy lại container.
*   `--name open-webui`: Đặt tên cho container là `open-webui` để dễ quản lý.
*   `--restart always`: Tự động khởi động lại Open WebUI mỗi khi máy tính được reboot hoặc Docker khởi động.
*   `ghcr.io/open-webui/open-webui:main`: Tên của image Docker trên GitHub Container Registry. `main` là phiên bản mới nhất.

3.  Sau khi lệnh chạy xong, bạn có thể kiểm tra container đang chạy bằng lệnh:
    ```bash
    docker ps
    ```
    Bạn sẽ thấy container `open-webui` trong danh sách.

---

### **Bước 3: Cấu hình Open WebUI để kết nối với các Model AI**

Bây giờ, hãy truy cập Open WebUI để hoàn tất cấu hình.

1.  Mở trình duyệt web trên **chính máy chủ `192.168.1.39`** và truy cập:
    `http://localhost:3000` hoặc `http://192.168.1.39:3000`

2.  **Đăng ký tài khoản đầu tiên:** Người dùng đầu tiên đăng ký sẽ tự động trở thành **Administrator**. Hãy tạo một tài khoản cho bạn.

3.  Sau khi đăng nhập, nhấn vào biểu tượng **cài đặt (Settings)** ở góc dưới bên trái.

4.  **Kết nối với Ollama:**
    *   Trong mục **Connections**, tìm đến **Ollama**.
    *   Trong ô **Ollama API URL**, nhập: `http://host.docker.internal:11434`
    *   Nhấn **Save**. Sau vài giây, bạn sẽ thấy model `llama3` (hoặc model bạn đã tải) xuất hiện ở danh sách model.

5.  **Kết nối với Google Gemini:**
    *   Trong mục **Connections**, tìm đến **Google**.
    *   Dán **API Key** bạn đã lấy ở Bước 1.5 vào ô **Gemini API Key**.
    *   Nhấn **Save**. Các model của Gemini (ví dụ: `gemini-pro`) sẽ xuất hiện.

6.  **Kết nối với LM Studio:**
    *   Trong mục **Connections**, nhấn **"Add a new connection"**.
    *   **Name:** Đặt tên dễ nhớ, ví dụ: `LM Studio Local`.
    *   **URL:** Nhập `http://host.docker.internal:1234`
    *   **API Key:** LM Studio không yêu cầu key thật, bạn có thể nhập bất cứ thứ gì, ví dụ: `lm-studio`.
    *   **Type:** Chọn **OpenAI Compatible**.
    *   Nhấn **Save**. Model bạn đang chạy trên LM Studio sẽ xuất hiện trong danh sách.

Bây giờ, ở giao diện chat chính, bạn có thể chọn bất kỳ model nào từ Ollama, Gemini, hay LM Studio để bắt đầu trò chuyện.

---

### **Bước 4: Cho phép truy cập từ máy khác trong mạng LAN/VPN**

Đây là bước cuối cùng để máy `192.168.1.22` có thể truy cập.

#### 4.1. Cấu hình Windows Defender Firewall

Windows Firewall mặc định sẽ chặn các kết nối từ bên ngoài. Bạn cần tạo một luật cho phép truy cập vào cổng `3000`.

1.  Trên máy chủ `192.168.1.39`, mở **Windows Defender Firewall with Advanced Security**.
    *   Cách nhanh nhất: Nhấn `Windows + R`, gõ `wf.msc` và nhấn Enter.
2.  Ở cột bên trái, nhấn chuột phải vào **Inbound Rules** và chọn **New Rule...**.
3.  Trong cửa sổ mới:
    *   **Rule Type:** Chọn **Port**. Nhấn Next.
    *   **Protocol and Ports:** Chọn **TCP**, và trong ô **Specific local ports**, nhập `3000`. Nhấn Next.
    *   **Action:** Chọn **Allow the connection**. Nhấn Next.
    *   **Profile:** Tích cả 3 ô **Domain**, **Private**, **Public**. (Để đảm bảo hoạt động qua VPN). Nhấn Next.
    *   **Name:** Đặt tên cho luật, ví dụ: `Open WebUI Access`. Nhấn **Finish**.

#### 4.2. Truy cập từ máy khách

1.  Đến máy `192.168.1.22` (hoặc bất kỳ máy nào trong cùng mạng LAN/VPN).
2.  Mở một trình duyệt web (Chrome, Firefox, Edge...).
3.  Nhập vào thanh địa chỉ: `http://192.168.1.39:3000`
4.  Bạn sẽ thấy trang đăng ký/đăng nhập của Open WebUI.
5.  Người dùng ở máy `192.168.1.22` có thể tự đăng ký một tài khoản mới. Tài khoản này sẽ là tài khoản người dùng thông thường. Bạn (Admin) có thể quản lý các tài khoản này trong phần **Admin Panel** của Open WebUI.

---

### **Tổng kết và kiểm tra**

*   **Trên máy chủ (`192.168.1.39`):**
    *   Docker Desktop đang chạy.
    *   Container `open-webui` đang chạy.
    *   Ollama service đang chạy (nếu muốn dùng model Ollama).
    *   LM Studio đang mở và server đang bật (nếu muốn dùng model LM Studio).
    *   Firewall đã cho phép cổng `3000`.
*   **Trên máy khách (`192.168.1.22`):**
    *   Truy cập `http://192.168.1.39:3000` thành công.
    *   Đăng ký và đăng nhập được.
    *   Có thể chọn và trò chuyện với các model từ Ollama, Gemini, LM Studio.

### **Gỡ rối (Troubleshooting)**

*   **Không truy cập được từ máy khác:**
    *   Kiểm tra lại lệnh `docker run` có đúng là `-p 0.0.0.0:3000:8080` không.
    *   Kiểm tra lại luật trong Windows Defender Firewall đã được tạo và bật đúng chưa.
    *   Tắt tạm thời phần mềm diệt virus của bên thứ ba (nếu có) để kiểm tra xem có phải nó chặn không.
*   **Open WebUI không kết nối được với Ollama/LM Studio:**
    *   Kiểm tra lại URL trong Settings có phải là `http://host.docker.internal:port` không.
    *   Đảm bảo Ollama đang chạy và LM Studio đang bật server.
*   **Lệnh `docker run` báo lỗi "port is already allocated":**
    *   Có thể một ứng dụng khác đang dùng cổng `3000`. Hoặc bạn đã chạy một container Open WebUI khác trước đó. Hãy chạy lệnh `docker stop open-webui` và `docker rm open-webui` rồi thử lại.
