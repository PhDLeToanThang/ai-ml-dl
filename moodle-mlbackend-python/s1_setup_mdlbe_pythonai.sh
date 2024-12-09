#!/bin/bash
clear
sudo apt update -y
sudo apt list --upgradable
sudo apt autoremove -y
sudo apt upgrade -y

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
#sudo ufw enable 


# Step 2 – Install Python 3.8
# You can install whatever version of python3 best suits your requirements, by using deadsnakes PPA, we'll install python 3.8, First, add the PPA:

# sudo add-apt-repository ppa:deadsnakes/ppa
# Now, you can install the required version of Python:

# sudo apt install python3.8 -y

# Gói moodle-mlbackend-python-3.0.5 via python 3.8, Pip 1.7.x support tensorflow 2.7.x:
# How to package a new version

## Requirements
# * PyPi credentials (moodlehq) to publish the new packages (twine will ask for them)
# * Install wheels and twine if they are not installed yet

#        pip install wheel
#        pip install twine

## Release process
# Make your changes and build the wheel (it generates the dist files)

#        python setup.py bdist_wheel --universal

# Install your new wheel locally (need to have moodlemlbackend>=3.0.2,<3.0.3 in /tmp/requirements.txt)
# 
# pip install -r /tmp/requirements.txt --no-index --find-links dist/moodlemlbackend-3.0.2-py2.py3-none-any.whl

# Run tests if any and make sure all passing
#        python3 -mpytest

# Add all new dist files, commit changes and push them upstream (create merge request).
# Once approved upload the generated dist file (credentials required)

#        twine upload dist/*

# Ensure that the VERSION git tag has been created.
# Verify that ```moodlemlbackend/VERSION``` version matches the new version and push tags
# Update the required moodle-mlbackend package version in Moodle core (```REQUIRED_PIP_PACKAGE_VERSION``` constant version in \mlbackend_python\processor class)
# More info about packaging and uploading as well as detailed instructions can be found in <https://packaging.python.org/tutorials/packaging-projects/>




# tensorflow==2.7.*
# sklearn
# numpy>=1.19.2,<1.20
# matplotlib>=3.0,<3.4
# boto3>=1.9.0,<1.10
# flask>=1.0.2,<2.0.0
# pytest-flask
# joblib>=0.13.0
# markupsafe<2.1.0
