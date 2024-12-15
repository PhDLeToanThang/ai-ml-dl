# Python 3.11 với jupyter notebook:
## Phần cài Python 3.11 trên Linux OS:
```
sudo apt install ufw -y
sudo apt install net-tools -y
sudo apt install gparted -y
sudo apt install qemu-guest-agent -y
sudo apt install gedit -y
sudo apt install ifupdown -y
sudo apt remove libreoffice-* -y
sudo apt-get install openvswitch-switch -y
sudo systemctl start openvswitch-switch
systemctl restart systemd-networkd
```
#Firewall configuration:
```
sudo ufw allow from 10.10.10.0/24 to any port ssh 
sudo ufw allow from 10.10.11.0/24 to any port ssh
sudo ufw allow from 192.168.100.0/24 to any port ssh
sudo ufw allow from 192.168.101.0/24 to any port ssh
sudo ufw allow from 192.168.1.0/24 to any port ssh 
sudo ufw allow from 192.168.2.0/24 to any port ssh  
sudo ufw allow from 192.168.3.0/24 to any port ssh
sudo systemctl restart ssh
sudo ufw enable 
sudo systemctl restart ufw
```
#####
# Phage 2: Install Python 3.8
# You can install whatever version of python3 best suits your requirements, by using deadsnakes PPA, we'll install python 3.8, First, add the PPA:
# setp 1: add cert:
```
cd ~
sudo add-apt-repository ppa:deadsnakes/ppa
```
# Step 2 Now, you can install the required version of Python:
```
sudo apt install python3.11 -y
sudo apt install -y python3-pip
sudo apt install -y build-essential libssl-dev libffi-dev python3-dev libfreetype6-dev libpng-dev pkg-config
```
# Setp 3. setup environment for python:
```
sudo apt install -y python3-venv
mkdir pythonai
cd pythonai
python3 -m venv pythonai
ls pythonai
```
# step 4. install pip version 1.7 flow enviroment of python 3.11
```
source pythonai/bin/activate
```
# Step 5.1. install manual:
```
pip -V
pip install tensorflow
pip install numpy
pip install matplotlib
pip install urllib3
pip install boto3
pip install botocore
pip install flask
pip install joblib
pip install markupsafe
pip install pandas
pip install pytest-flask
pip install wheel
pip install twine
pip install jmespath
pip install docutils
pip install -U pip
pip install Cython
pip install scikit-learn
pip3 list
cd ~
cd pythonai/
source pythonai/bin/activate
```

> Hướng dẫn chi tiết các bước cấu hình để tôi có thể publish web jupyter notebook khi hiện thời chỉ có http://localhost:8888/lab
Để có thể public một Jupyter Notebook trên web khi bạn chỉ có localhost:8888/lab (tức là Jupyter Lab chạy trên máy của bạn), 
bạn cần thực hiện các bước sau:

1. Tạo một tài khoản trên các dịch vụ miễn phí như Google Cloud Platform, Amazon Web Services (AWS) mình dùng VM.
2. Cài đặt và cấu hình Jupyter Notebook Server trên VM:
3. Sử dụng terminal hoặc command prompt để kết nối đến máy chủ VM của bạn.
4. Cài đặt Jupyter Notebook trên máy chủ VM bằng câu lệnh: 
```
pip install jupyter.
```
5. Tạo một profile cho Jupyter bằng câu lệnh: 
```
jupyter notebook --generate-config
```

6. Mở file cấu hình Jupyter bằng trình soạn thảo và tìm đến dòng c.NotebookApp.ip để cấu hình IP của máy chủ.
```
/root/.jupyter/jupyter_notebook_config.py
```
thêm 2 dòng cấu hình sau:
```
c.NotebookApp.ip = '0.0.0.0' # để cho phép truy cập từ mọi IP.
c.NotebookApp.port = 8888 để # cấu hình cổng truy cập.
```

Khởi chạy Jupyter Notebook trên VM, sử dụng câu lệnh:
```
jupyter notebook --no-browser --port=8888 # để khởi động Jupyter Notebook Server trên VM.
```
Để truy cập vào Jupyter Notebook từ trình duyệt, truy cập http://[địa chỉ IP của máy chủ]:8888.
```
http://192.168.100.37:8888
```

Tóm lại, Public Jupyter Notebook trên Web mạng nội bộ:
Để public Jupyter Notebook, bạn có thể tạo một notebook mới hoặc mở notebook đã có.
Khi bạn mở notebook, sẽ có một URL tương ứng hiển thị trên trình duyệt.
Copy URL đó và chia sẻ cho người khác để họ có thể truy cập Jupyter Notebook của bạn trên web.
**Lưu ý:** Việc cấu hình và public Jupyter Notebook trên Cloud yêu cầu kiến thức về quản trị hệ thống cơ bản. Đảm bảo bạn hiểu rõ về bảo mật và quản lý truy cập khi public một Jupyter Notebook trên internet.


## Phần Cài Python 3.11 trên Windows OS:
Hướng dẫn cài đặt Python 3.11 trên Windows 11:
> **Bước 1. Tải và cài Python3.11 trên windows x64**
- Tạo thư mục cd c:\python311
- Tải bộ cài python3.11 và cài vào thư mục c:\python311
- Tiếp theo dùng cmd /admin gõ lệnh cd c:\python311 và
- python.exe -m pip install --upgrade pip

> **Bước 2. Python Jupyter notebook:**

- Installing Jupyter
Get up and running on your computer
Project Jupyter’s tools are available for installation via the Python Package Index, the leading repository of software created for the Python programming language.
This page uses instructions with pip, the recommended installation tool for Python.

## JupyterLab:
Install JupyterLab with pip:
```
pip install jupyterlab
```
Once installed, launch JupyterLab with:
```
jupyter lab
```

## Jupyter Notebook:
Install the classic Jupyter Notebook with:
```
pip install notebook
```
To run the notebook:
```
jupyter notebook
```
