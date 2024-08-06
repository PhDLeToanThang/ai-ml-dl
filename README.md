# AI/LLM/DL 

## Tác động Ảnh hưởng đầu tiên có lợi cho giới CNTT:

1. Business Analytic and Data Analytics by CI/CD,Agile,Scrum with Copilot:

- Phân tích dữ liệu và phân tích kinh doanh bằng CI/CD, Agile, Scrum với khai thác sử dụng AI/ML Local DB làm Co-pilot fix thuật toán, sửa code và Troubleshoot.

```comment
A career in Data Analysis:
Business today recognize the untapped value in data and
data analytics as a crucial factor for business competitiveness.
To drive their data analytics initiatives, companies are hiring and upskilling people.
They're expanding their teams and creating centers of excellence to set up a multipronged data and
analytics pratice in their organizations.
```
```vi_translate
Ngày nay, các doanh nghiệp nhận ra giá trị chưa được khai thác trong dữ liệu và phân tích
dữ liệu là yếu tố quan trọng đối với sự cạnh tranh kinh doanh.
Để thúc đẩy các sáng kiến phân tích dữ liệu của mình, các công ty đang tuyển dụng và nâng cao kỹ năng cho nhân viên.
Họ mở rộng đội ngũ và tạo ra các trung tâm xuất sắc để thiết lập một thực hành phân tích
dữ liệu và phân tích đa mục tiêu trong tổ chức của họ.
```

2. IT Helpdesk - KB vs Troubleshooting:

## Phần 1. Cài và chạy OLLAMA 3.1 với Python3.12, Jupyter Notebook trên Windows 11:

Hướng dẫn cài đặt Open-WebUI và OLLAMA trên Windows 11:

Bước 1: Tải mã Open-WebUI

Mở trình duyệt web và truy cập vào trang chủ của Open-WebUI: https://open-web-ui.com/

Click vào nút "Tải mã" (Download) để tải mã Open-WebUI.

Chọn định dạng tệp (ví dụ: .msi) và tên tệp.

Tải mã hoàn tất, click vào nút "Lưu trữ" (Save) để lưu trữ tệp.

Bước 2: Cài đặt Open-WebUI

Mở File Explorer và tìm đến vị trí tải mã Open-WebUI.

Click vào nút "Cài đặt" (Install) để cài đặt Open-WebUI.

Chọn ngôn ngữ cài đặt và đọc các thông tin về quyền lợi và nghĩa vụ.

Nhấn "Next" để tiếp tục cài đặt.

Cài đặt hoàn tất, click vào nút "Finish" để đóng cửa sổ cài đặt.

Bước 3: Tải mã OLLAMA

Mở trình duyệt web và truy cập vào trang chủ của OLLAMA: https://ollama.io/

Click vào nút "Tải mã" (Download) để tải mã OLLAMA.

Chọn định dạng tệp (ví dụ: .msi) và tên tệp.

Tải mã hoàn tất, click vào nút "Lưu trữ" (Save) để lưu trữ tệp.

Bước 4: Cài đặt OLLAMA

Mở File Explorer và tìm đến vị trí tải mã OLLAMA.

Click vào nút "Cài đặt" (Install) để cài đặt OLLAMA.

Chọn ngôn ngữ cài đặt và đọc các thông tin về quyền lợi và nghĩa vụ.

Nhấn "Next" để tiếp tục cài đặt.

Cài đặt hoàn tất, click vào nút "Finish" để đóng cửa sổ cài đặt.

Bước 5: Xử lý cài đặt

Mở Open-WebUI và OLLAMA trên màn hình chính của Windows 11.

Nhấn F5 để mở ứng dụng Open-WebUI.

Lọc tìm "Open Web UI" và mở ứng dụng.

Nhấn F5 để mở ứng dụng OLLAMA.

Bước 6: Cài đặt OLLAMA

Dọn lịch trình OLLAMA.

Cài đặt OLLAMA.

Thay đổi tên cho dịch vụ OLLAMA (ví dụ: OLLAMA).

Lưu trữ mật khẩu OLLAMA.

![image](https://github.com/user-attachments/assets/a0b0ecab-40be-40c2-9b7d-f121954121f7)

Truy cập: http://localhost:8080

<hr></hr>

## Phần 2. Cài và chạy OLLAMA 3.1 trên Ubuntu linux:

### Bước 1. Mở terminal của Ubuntu.

- Copy toàn bộ đoạn code bash / sh dưới đây và dán vào 1 file ollama31.sh

```bash
##############################################
#    What's new Python 3.12.3 with OLLAMA in Ubuntu 24.04
##############################################
#!/bin/bash -e
#Phần 1. Các bước cài Python trên Unix/Linux OS:
#Install Ollama:
#Open a terminal on your Ubuntu server.
#Run the following command to install Ollama: 

curl -fsSL [^1^][4] | sh

#This will download and install Ollama along with its supported open-source language models.
#Verify Installation:
#Confirm that Ollama is installed by running 
ollama --version #in the terminal.

#You should see the version information if the installation was successful.
#Run Language Models:
#Use Ollama to download and run specific language models. For example:
#To run the Mistral 7B model, use: ollama run Mistral
#Explore other models supported by Ollama as needed.

#Phần 2- Optional: Web Interface (Open WebUI):
#If you prefer a web-based interface, you can install Ollama WebUI:
#Install Snapd (if not already installed): 
sudo apt update && sudo apt install snapd

#Install Ollama WebUI: 
sudo snap install ollama-webui --beta
#Access the WebUI at http://localhost:8080/auth/ in your browser.

#Phần 3-Install model ollama3
snap install ollama
ollama pull llama3
#ref: https://github.com/ollama/ollama/blob/main/README.md#import-from-gguf
#list models on ollama: https://ollama.com/library
ollama pull medllama2
ollama pull sqlcoder
ollama pull gemma:7b
#https://ollama.com/library/sqlcoder
#https://ollama.com/library/medllama2
#curl -X POST http://localhost:11434/api/generate -d '{
#  "model": "medllama2",
#  "prompt":"A 35-year-old woman presents with a persistent dry cough, shortness of breath, and fatigue. She is initially suspected of having asthma, but her spirometry results do not improve with bronchodilators. What could be the diagnosis?"
# }'
```

- Chạy bằng lệnh:  bash ./ollama31.sh

<hr></hr>

## Phần 3. Khai thác sử dụng LLAMA 3.1:

_ví dụ 1: Đặt câu hỏi cố gắng đưa thông tin đầy đủ, như phiên bản, số hiệu phần mềm_ 

```q
Hướng dẫn chi tiết các bước nâng cấp từ vSphere 7.0u3 lên vSphere 8.0u2 và vCenter 7 HA lên vCenter 8u2 Enhanced Link Mode ?
```

![image](https://github.com/user-attachments/assets/2000ee1e-b2e0-4f9c-8323-b8e2d6096d56)

_Ví dụ 2: Tự động recording và transcription viết từ audio.micro sang văn bản tiếng nguyên gốc, làm phụ đề_

![image](https://github.com/user-attachments/assets/4ed9c9ec-22dc-47f2-9635-9498612585b5)

![image](https://github.com/user-attachments/assets/2a7f0067-dc0e-40ce-aabe-18767a31c128)

_Ví dự 3: Thảo luận về nội dung câu hỏi đề thi và đáp án đúng_
```q
Hãy tìm cho tôi 3 đáp án đúng trong câu hỏi sau, và giải thích tại sao bạn chọn 3 đáp án đó? 
An administrator is working with VMware Support and is asked to provide log bundles for the ESXi hosts in an environment.
Which three options does the administrator have? (Choose three.)
```
```a
A. Generate a combined log bundle for all ESXi hosts using the vCenter Management Interface
B. Generate a separate log bundle for each ESXi host using the vSphere Host Client.
C. Generate a combined log bundle for all ESXi hosts using the vSphere Client.
D. Generate a separate log bundle for each ESXi host using the vSphere Client.
E. Generate a separate log bundle for each ESXi host using the vCenter Management Interface.
F. Generate a combined log bundle for all ESXi hosts using the vSphere Host Client.
```

![image](https://github.com/user-attachments/assets/726fd8db-bd5e-4ca7-81d2-77528b7044b7)

-> AI local trả lời và chọn 3 đáp án trên vẫn sai nhé:

"Cannot be "Generate a combined log bundle for all ESXi hosts using the vCenter Management Interface" or "Generate a separate log bundle for each ESXi host using the vCenter Management Interface": you don't have access to the ESXi logs from the VAMI Cannot be "Generate a combined log bundle for all ESXi hosts using the vSphere Host Client." : for the Host Client, you can only get the logs of the corresponding host, not the others. So correct answer is: BCD"
