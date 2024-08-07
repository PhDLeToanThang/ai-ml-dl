# AI/LLM/DL 

## Tác động Ảnh hưởng đầu tiên có lợi cho giới CNTT:

**1. Business Analytic and Data Analytics by CI/CD,Agile,Scrum with Copilot:**

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

**2. IT Helpdesk - KB vs Troubleshooting:**

## Phần 1. Cài và chạy OLLAMA 3.1 với Python3.11 trên Windows 11:

Hướng dẫn cài đặt Open-WebUI và OLLAMA trên Windows 11:
> **Bước 1: Tải và cài Python3.11 trên windows x64**
- Tạo thư mục cd c:\python311
- Tải bộ cài python3.11 và cài vào thư mục c:\python311
- Tiếp theo dùng cmd /admin gõ lệnh cd c:\python311 và
- python.exe -m pip install --upgrade pip

> **Bước 2: Tải mã Open-WebUI**

Mở trình duyệt web và truy cập vào trang chủ của Open-WebUI: https://open-web-ui.com/

Click vào nút "Tải mã" (Download) để tải mã Open-WebUI.

Chọn định dạng tệp (ví dụ: .msi) và tên tệp.

Tải mã hoàn tất, click vào nút "Lưu trữ" (Save) để lưu trữ tệp.

> **Bước 3: Cài đặt Open-WebUI**

Sau khi cài xong python3.11, chúng ta dùng lệnh cmd /admin chuyển về thư mục này

cd c:\python311

tiếp theo gõ lệnh cài open-webui: python -m pip install open-webui

![image](https://github.com/user-attachments/assets/2f7264ca-c379-44ca-ace3-ff935b3223dc)

> **Bước 4: Tải mã OLLAMA**

Mở trình duyệt web và truy cập vào trang chủ của OLLAMA: https://ollama.io/

Click vào nút "Tải mã" (Download) để tải mã OLLAMA.

Chọn định dạng tệp (ví dụ: .msi) và tên tệp.

Tải mã hoàn tất, click vào nút "Lưu trữ" (Save) để lưu trữ tệp.

> **Bước 5: Cài đặt OLLAMA**

Mở File Explorer và tìm đến vị trí tải mã OLLAMA.

Click vào nút "Cài đặt" (Install) để cài đặt OLLAMA.

Chọn ngôn ngữ cài đặt và đọc các thông tin về quyền lợi và nghĩa vụ.

Nhấn "Next" để tiếp tục cài đặt.

Cài đặt hoàn tất, click vào nút "Finish" để đóng cửa sổ cài đặt.

> **Bước 6. Mở dịch vụ vs Truy cập open-webui**

![image](https://github.com/user-attachments/assets/a0b0ecab-40be-40c2-9b7d-f121954121f7)

- Mở cmd và nhập lệnh: open-webui serve

![image](https://github.com/user-attachments/assets/f5bf50b1-ac73-4aef-858d-2f7947813f49)

Lần đầu truy cập: [http://localhost:8080](http://localhost:8080/auth)  

Chúng ta cần đăng ký account mới qua email và nhập mật khẩu local.

![image](https://github.com/user-attachments/assets/48e8e307-dc4c-4dce-9560-d6d39a3d9348)

> **Bước 7. Cài thêm các Models hỗ trợ OLLama3**

- Mở cmd và nhập các lệnh:
- ollama pull llama3
- ollama pull medllama2
- ollama pull sqlcoder
- ollama pull gemma:7b

#Tham khảo các thư viện Models ollama: https://ollama.com/library

- Sau khi download xong các modles cần thì trên màn web sẽ có thể chọn:

![image](https://github.com/user-attachments/assets/d54e9040-6db1-41a8-bcb0-5dbbacd9b5b3)

<hr></hr>

## Phần 2. Cài và chạy OLLAMA 3.1 trên Ubuntu linux:

> **Bước 1. Mở terminal của Ubuntu.**

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

> **Bước 2. Chạy bằng lệnh:**
```bash
bash ./ollama31.sh
```



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

# Phần 4. Cách cài thêm các Models cho các lĩnh vực AI/LLAMA khác:

_Theo bài viết: https://www.artificialintelligence-news.com/news/microsoft-unveils-phi-3-family-compact-language-models/_

_Tác giả: Ryan Daws is a senior editor at TechForge Media_

Trong sơ đồ trên đây cho rằng SLM (Small Language Models) nhỏ và hiệu quả cao thì có MS Phi3

![image](https://github.com/user-attachments/assets/6ebf9db4-8c87-41fa-ae13-d7a1dceec3de)

Vậy ta có thể truy cập vào trang Huggingface.co để tìm 

https://huggingface.co/models?sort=trending&search=phi

![image](https://github.com/user-attachments/assets/362607f4-f622-4669-9890-b305dd68ca11)

Nhưng do chúng ta dùng Ollama3.1 lầm Agent Client LLM trên nền Windows, nên chúng ta truy cập thư viện của Ollama để cài thêm Model Phi3 nhanh hơn

https://ollama.com/library?q=phi3

![image](https://github.com/user-attachments/assets/9e95f0bf-cf4a-4546-a52f-6f502862f5a5)

![image](https://github.com/user-attachments/assets/662d7ca0-e0fc-4c23-880e-c62e8505e9f7)

Xuất hiện dòng lệnh:  

**Bước 1. Mở terminal hoặc cmd**

![image](https://github.com/user-attachments/assets/f904e374-d94a-4ee6-bb2b-bc38a2a90dca)

Chuyển tới thư mục: cd c:\python311

Nhập lệnh: ollama run phi3:3.8b

![image](https://github.com/user-attachments/assets/4a0299ca-bc95-40a7-ac02-7ac333e4cb22)

**Bước 2. Chúng ta có thể chat ở ngay màn lệnh**

![image](https://github.com/user-attachments/assets/caf64b41-61cc-4154-b18e-d1a0784fcbc9)

**hoặc Bước 3. Chuyển sang màn Browser: Open-webui và refresh**

![image](https://github.com/user-attachments/assets/6b8c5ed9-2bc8-4a2f-8a6b-7d8d017a1967)

**Bạn cũng có thể tìm trong Ollama.com để download các Models hiện đại như:

gpt-3.5-turbo:  ollama run Eomer/gpt-3.5-turbo

taozhiyuai/openbiollm-llama-3: ollama run taozhiyuai/openbiollm-llama-3:70b_q2_k
Advancing Open-source Large Language Models in Medical Domain

cniongolo/biomistral:  ollama run cniongolo/biomistral
A Quantize version of Biomistral made by MaziyarPanahi on HuggingFace. BioMistral-7B-GGUF Model creator: BioMistral Original model: BioMistral/BioMistral-7B

monotykamary/medichat-llama3: ollama run monotykamary/medichat-llama3
Built upon the powerful LLaMa-3 architecture and fine-tuned on an extensive dataset of health information, this model leverages its vast medical knowledge to offer clear, comprehensive answers.
