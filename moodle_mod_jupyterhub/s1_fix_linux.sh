#!/bin/bash -e
clear
sudo apt update -y
sudo apt list --upgradable
sudo apt autoremove -y
sudo apt upgrade -y

# Cấu hình Remote Desktop Access RDP 3389 tới máy chủ vật lý hoặc máy ảo Ubuntu 24.04 LTS server
# https://thangletoan.wordpress.com/2023/10/31/cau-hinh-remote-desktop-access-rdp-3389-toi-may-chu-vat-ly-hoac-may-ao-ubuntu-20-x-22-x-lts-server/
sudo apt install xrdp -y
sudo apt install xserver-xorg-core -y
sudo apt install xserver-xorg-input-all -y
sudo apt install xorgxrdp -y

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


# (dải ipv4 cho guacamole Server tới con VM cần điều khiển) 
#sudo ufw allow from 192.168.100.0/24 to any port 3389   

#Reboot system:  (không cần thiết)
#sudo reboot

sudo apt install wget -y
sudo apt install ufw -y
sudo apt install net-tools -y
sudo apt install install qemu-guest-agent -y
sudo apt install gedit -y
sudo apt install gparted -y
sudo apt install ifupdown -y

# After you already have Cockpit on your server, point your web browser to: https://ip-address-of-machine:9090
sudo apt install ubuntu-desktop -y

#Firewall configuration:   
sudo ufw allow 3389/tcp
sudo ufw allow ssh/tcp

#sudo ufw enable 
#Cài đặt gói phần mềm để sử dụng gói apt qua giao thức HTTPS
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
#Install Certbot
sudo apt install certbot python3-certbot-nginx -y


#Cập nhật lại danh sách gói phần mềm và cài đặt Docker:
sudo apt update -y
sudo apt-get update --fix-missing -y 
sudo apt upgrade -y
sudo apt autoremove -y

#Reboot system:  (không cần thiết)
#sudo reboot