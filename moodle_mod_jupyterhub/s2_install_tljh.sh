#!/bin/bash
########################
# How To Install JupyterHub on Ubuntu 24.04 LTS Server
# cài đặt The Littlest JupyterHub (TLJH)
# Trong JupyterHub, chúng ta có thể tạo một Hub đa người dùng để tạo, quản lý và ủy quyền nhiều phiên bản của máy chủ sổ tay Jupyter một người dùng. 
# JupyterHub có thể cài đặt trên phần cứng đám mây hoặc tại chỗ. 
# Nó giúp có thể phục vụ môi trường khoa học dữ liệu được cấu hình sẵn cho bất kỳ người dùng nào trên thế giới.
# Chúng ta đang cài đặt và cấu hình The Littlest JupyterHub (TLJH), Conda với tên miền và cài đặt chứng chỉ SSL/TLS public.
# https://hostnextra.com/learn/tutorials/how-to-install-jupyterhub-on-ubuntu
########################

############### Tham số cần thay đổi ở đây ###################
echo "FQDN: e.g: demo.company.vn"   # Đổi địa chỉ web thứ nhất Website Master for Resource code - để tạo cùng 1 Source code duy nhất 
read -e FQDN
echo "admin-username: e.g: admin"   # Tên Admin User access Jupyterhub
read -e adminusername
echo "admin-password: e.g: P@$$w0rd-1.22"
read -s adminpass
echo "Your Email address fro Certbot e.g: thang@company.vn" # Địa chỉ email của bạn để quản lý CA
read -e emailcertbot

pythonversion="3"

echo "run install? (y/n)"
read -e run
if [ "$run" == n ] ; then
  exit
else

#Step 1. Install NGINX
sudo apt-get update -y
sudo apt-get install nginx -y
sudo systemctl stop nginx.service
sudo systemctl start nginx.service
sudo systemctl enable nginx.service

#Step 2. Installing Python 
sudo apt install python3 python3-dev git curl -y

#Step 3. Configuring Firewall
ufw allow 80/tcp
ufw allow 443/tcp

#Step 4. Installing JupyterHub
curl -L https://tljh.jupyter.org/bootstrap.py | sudo -E python3 - --admin ${adminusername}:${adminpass}

#Step 5. Enabling HTTPS
sudo tljh-config set https.enabled true
sudo tljh-config set https.letsencrypt.email $emailcertbot
sudo tljh-config add-item https.letsencrypt.domains $FQDN
sudo tljh-config show
sudo tljh-config reload proxy

# Step 6. Installing Conda
sudo -E conda install -c conda-forge gdal
sudo -E pip install there

fi
