#!/bin/bash
clear
sudo apt update -y
sudo apt list --upgradable
sudo apt autoremove -y
sudo apt upgrade -y

#####
# Phage 1: Install tools for OS Linux:

# Cấu hình Remote Desktop Access RDP 3389 tới máy chủ vật lý hoặc máy ảo Ubuntu 20.x/22.x LTS server
# https://thangletoan.wordpress.com/2023/10/31/cau-hinh-remote-desktop-access-rdp-3389-toi-may-chu-vat-ly-hoac-may-ao-ubuntu-20-x-22-x-lts-server/
sudo apt install xrdp -y
sudo apt install xserver-xorg-core -y
sudo apt install xserver-xorg-input-all -y
sudo apt install xorgxrdp -y
sudo apt install ssh -y
#You also need to grant access to the /etc/ssl/private/ssl-cert-snakeoil.key file for xrdp user. 
#It is available to members of the ssl-cert group by default.
# add xrdp into ssl-cert group
sudo adduser xrdp ssl-cert

# start xrdp service
sudo systemctl start xrdp

# check xrdp state
systemctl is-active xrdp 

#active
sudo systemctl enable xrdp # start xrdp on system start

#Firewall configuration:   
# (dải ipv4 cho guacamole Server tới con VM cần điều khiển) 
sudo ufw allow from 10.10.10.0/24 to any port 3389 
sudo ufw allow from 10.10.11.0/24 to any port 3389 
sudo ufw allow from 192.168.100.0/24 to any port 3389  
sudo ufw allow from 192.168.101.0/24 to any port 3389  
sudo ufw allow from 192.168.1.0/24 to any port 3389  
sudo ufw allow from 192.168.2.0/24 to any port 3389  
sudo ufw allow from 192.168.3.0/24 to any port 3389  

#Reboot system:  (không cần thiết)
#sudo reboot

sudo apt install ufw -y
sudo apt install net-tools -y
sudo apt install gparted -y
sudo apt install qemu-guest-agent -y
sudo apt install gedit -y
sudo apt install ifupdown -y

# After you already have Cockpit on your server, point your web browser to: https://ip-address-of-machine:9090
# sudo apt install ubuntu-desktop -y
sudo apt remove libreoffice-* -y

sudo apt-get install openvswitch-switch -y
sudo systemctl start openvswitch-switch
systemctl restart systemd-networkd

#Firewall configuration:
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

#####
# Phage 2: Install Python 3.8
# You can install whatever version of python3 best suits your requirements, by using deadsnakes PPA, we'll install python 3.8, First, add the PPA:
# setp 1: add cert:
cd ~
sudo add-apt-repository ppa:deadsnakes/ppa

# Step 2 Now, you can install the required version of Python:
sudo apt install python3.8 -y
sudo apt install -y python3-pip
sudo apt install -y build-essential libssl-dev libffi-dev python3-dev libfreetype6-dev libpng-dev pkg-config
# Setp 3. setup environment for python:
sudo apt install -y python3-venv
mkdir open-webui
cd open-webui
python3 -m venv open-webui
ls open-webui

# step 4. install pip version 1.7 flow enviroment of python 3.8
source open-webui/bin/activate

# Step 5.1. install manual:
pip -V
pip install tensorflow==2.7
pip install numpy==1.19.2
pip install matplotlib==3.0
pip install urllib3==1.20
pip install boto3==1.9.253
pip install botocore==1.12.253
pip install flask==1.0.2
pip install joblib==0.13.0
pip install markupsafe==2.1.0
pip install pandas==1.3
pip install numpy==1.19.5

pip install sklearn
pip install pytest-flask==1.3.0
pip3 install wheel=0.45.1
pip3 install twine==3.0.0
pip install jmespath== 0.10.0
pip install docutils==0.15.2

# check version supported
pip3 list
pip install -U pip
pip install Cython
pip install scikit-learn==0.21.3
pip install moodlemlbackend
pip install --upgrade --force-reinstall moodlemlbackend

pip show moodlemlbackend
#(open-webui) root@mdlbepy1:~/open-webui# pip show moodlemlbackend
#Name: moodlemlbackend
#Version: 3.0.5
#Summary: Python machine learning backend used by mlbackend_python Moodle plugin
#Home-page: https://github.com/moodlehq/moodle-mlbackend-python
#Author: Moodle HQ
#Author-email: integration@moodle.com
#License: GPLv3
#Location: /root/open-webui/open-webui/lib/python3.8/site-packages
#Requires: boto3, flask, itsdangerous, Jinja2, joblib, matplotlib, numpy, scikit-learn, tensorflow
#Required-by:
#(open-webui) root@mdlbepy1:~/open-webui#
