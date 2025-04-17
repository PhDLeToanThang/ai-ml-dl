#!/bin/bash
########################
# Phần 1: JupyterHub và JupyterLab on Ubuntu 24.04 LTS Server
# cài đặt The JupyterHub + JupyterLab (JHJL)
# Thiết lập JupyterHub và JupyterLab trong môi trường ảo.
# https://jupyterhub.readthedocs.io/en/1.2.1/installation-guide-hard.html
########################

############### Tham số cần thay đổi ở đây ###################
echo "FQDN: e.g: demo.company.vn"   # Đổi địa chỉ web thứ nhất Website Master for Resource code - để tạo cùng 1 Source code duy nhất 
read -e FQDN
echo "admin-username: e.g: admin"   # Tên Admin User access Jupyterhub
read -e adminusername
echo "admin-password: e.g: P@$$w0rd-1.22"
read -s adminpass
echo "user name: e.g: user"   # Tên User access Jupyterhub
read -e usernamejh
echo "user-password: e.g: P@$$w0rd-1.22"
read -s userpassjh
echo "Your Email address fro Certbot e.g: thang@company.vn" # Địa chỉ email của bạn để quản lý CA
read -e emailcertbot

pythonversion="3"

echo "run install? (y/n)"
read -e run
if [ "$run" == n ] ; then
  exit
else

#Step 1. Install Nginx
sudo apt-get update -y
sudo apt-get install nginx -y
sudo systemctl stop nginx.service
sudo systemctl start nginx.service
sudo systemctl enable nginx.service

#Step 2. Installing Python 
sudo apt install python3 python3-dev python3-venv git curl -y

#Step 3. Configuring Firewall
ufw allow 80/tcp
ufw allow 443/tcp

#Step 4. tạo một môi trường ảo trong '/opt/jupyterhub':
#Thư mục '/opt' là nơi các ứng dụng không thuộc về hệ điều hành thường được cài đặt . 
#Cả jupyterlab và jupyterhub sẽ được cài đặt vào virtualenv này. Tạo nó bằng lệnh:

sudo python3 -m venv /opt/jupyterhub/

#Step 5. cài đặt các gói Python cần thiết vào môi trường ảo mới
sudo /opt/jupyterhub/bin/python3 -m pip install numpy pandas matplotlib
sudo /opt/jupyterhub/bin/python3 -m pip install wheel
sudo /opt/jupyterhub/bin/python3 -m pip install jupyterhub jupyterlab jupyter-core jupyterhub-idle-culler
sudo /opt/jupyterhub/bin/python3 -m pip install ipywidgets

#Step 6. JupyterHub hiện cũng mặc định yêu cầu configurable-http-proxy, cần nodejsvà npm. 
# Do đó, các phiên bản có sẵn trong Ubuntu cần phải được cài đặt trước (chúng hơi cũ nhưng vẫn ổn cho nhu cầu của chúng tôi)
sudo apt install nodejs npm -y
sudo npm install -g configurable-http-proxy

#Step 7. Tạo cấu hình cho JupyterHub 
# Để giữ mọi thứ lại với nhau, chúng ta đặt tất cả các cấu hình vào thư mục được tạo cho virtualenv, trong /opt/jupyterhub/etc/
sudo mkdir -p /opt/jupyterhub/etc/jupyterhub/
cd /opt/jupyterhub/etc/jupyterhub/

#Sau đó tạo tệp cấu hình mặc định
sudo /opt/jupyterhub/bin/jupyterhub --generate-config
# Điều này sẽ tạo ra tệp cấu hình mặc định /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py
# Đường dẫn tới file cấu hình
config_file="/opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py"

#Tìm kiếm dòng c.Spawner.default_url
if grep -q "^c.Spawner.default_url" "$config_file"; then
    # Nếu tìm thấy, thay thế bằng dòng mới
    sed -i "s|^c.Spawner.default_url.*|c.Spawner.default_url = '/lab'|" "$config_file"
    echo "Đã cập nhật c.Spawner.default_url trong file cấu hình."
else
    # Nếu không tìm thấy, thêm dòng mới vào cuối file
    echo "c.Spawner.default_url = '/lab'" >> "$config_file"
    echo "Đã thêm c.Spawner.default_url vào file cấu hình."
fi

#Step 8. Thiết lập dịch vụ Systemd
sudo mkdir -p /opt/jupyterhub/etc/systemd
sudo cat > /opt/jupyterhub/etc/systemd/jupyterhub.service <<EOF
[Unit]
Description=JupyterHub
After=syslog.target network.target

[Service]
User=root
Environment="PATH=/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/jupyterhub/bin"
ExecStart=/opt/jupyterhub/bin/jupyterhub -f /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py

[Install]
WantedBy=multi-user.target
EOF

#  liên kết tượng trưng tệp của mình vào thư mục systemd:
sudo ln -s /opt/jupyterhub/etc/systemd/jupyterhub.service /etc/systemd/system/jupyterhub.service

# systemd tải lại các tệp cấu hình 
sudo systemctl daemon-reload

# kích hoạt dịch vụ
sudo systemctl enable jupyterhub.service

# chúng ta có thể bắt đầu ngay bằng cách sử dụng:
sudo systemctl start jupyterhub.service

# kiểm tra tình trạng dịch vụ:
#sudo systemctl status jupyterhub.service

#Phần 2: Môi trường Conda
#Step 9. Cài đặt conda cho toàn bộ hệ thống
# Chúng tôi sẽ sử dụng condađể quản lý môi trường Python
curl https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc | gpg --dearmor > conda.gpg
sudo install -o root -g root -m 644 conda.gpg /etc/apt/trusted.gpg.d/

# Thêm kho lưu trữ Debian
echo "deb [arch=amd64] https://repo.anaconda.com/pkgs/misc/debrepo/conda stable main" | sudo tee /etc/apt/sources.list.d/conda.list

# Cài đặt conda
sudo apt update -y
sudo apt install conda -y

# liên kết tượng trưng tập lệnh thiết lập shell conda với thư mục 'drop in'
sudo ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh

# Cài đặt môi trường conda mặc định cho tất cả người dùng
sudo mkdir /opt/conda/envs/

# bạn PHẢI cài đặt ít nhất ipykernel
sudo /opt/conda/bin/conda create --prefix /opt/conda/envs/python python=3.7 ipykernel

# Cài đặt vào JupyterHub virtualenv để tránh môi trường conda xuất hiện ở nơi không mong đợi.
sudo /opt/conda/envs/python/bin/python -m ipykernel install --prefix=/opt/jupyterhub/ --name 'python' --display-name "Python (default)"

# Cài đặt trên toàn hệ thống bằng cách đưa vào /usr/local sẽ hữu ích nếu các hạt nhân có thể được sử dụng bởi các dịch vụ khác 
# hoặc nếu bạn muốn sửa đổi cài đặt JupyterHub độc lập với môi trường conda.
sudo /opt/conda/envs/python/bin/python -m ipykernel install --prefix /usr/local/ --name 'python' --display-name "Python (default)"

#Step 10. Thiết lập môi trường conda của riêng người dùng
# người dùng sẽ phải thiết lập môi trường của riêng họ bằng shell. 
# Khi đăng nhập, họ phải chạy. 
# Sau đó, họ có thể sử dụng conda để thiết lập môi trường của họ, mặc dù họ cũng phải cài đặt 
# Sau khi hoàn tất, họ có thể kích hoạt kernel của mình bằng cách sử dụng:conda init/opt/conda/bin/conda/ipykernel
sudo /opt/conda/envs/python/bin/python -m ipykernel install --name 'python-my-env' --display-name "Python My Env"

#Step 11. Thiết lập proxy ngược, Sử dụng Nginx:
# Đầu tiên, chỉnh sửa tệp cấu hình /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py

# Tìm kiếm dòng c.JupyterHub.bind_url
if grep -q "^c.JupyterHub.bind_url" "$config_file"; then
    # Nếu tìm thấy, thay thế bằng dòng mới
    sed -i "s|^c.JupyterHub.bind_url.*|c.JupyterHub.bind_url = 'http://:8000/jupyter'|" "$config_file"
    echo "Đã cập nhật c.JupyterHub.bind_url trong file cấu hình."
else
    # Nếu không tìm thấy, thêm dòng mới vào cuối file
    echo "c.JupyterHub.bind_url = 'http://:8000/jupyter'" >> "$config_file"
    echo "Đã thêm c.JupyterHub.bind_url vào file cấu hình."
fi	

# Đường dẫn tới file jupyterhub_config.py
CONFIG_FILE="/opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py"

# Các tham số cần thêm vào file
PARAMS="
# Các tham số cấu hình mới
c.Authenticator.allowed_users = {'${adminusername}','${usernamejh}'} 
c.Authenticator.admin_users = {'${adminusername}'}
c.PAMAuthenticator.admin_groups = {'wheel'}
#If JupyterHub.admin_access is set to True, then admins have permission to log in as other users on their respective machines, for debugging
JupyterHub.admin_access = True
#Use LocalAuthenticator to create system users
c.LocalAuthenticator.create_system_users = True
#Spawners and single-user notebook servers
c.Spawner.notebook_dir = '~/notebooks'
c.JupyterHub.ip = '192.168.100.26'
c.JupyterHub.hub_ip = '0.0.0.0' 
c.JupyterHub.port = 443
"
# Ghi thêm vào cuối file
echo "$PARAMS" >> "$CONFIG_FILE"
echo "Cấu hình đã được thêm vào $CONFIG_FILE"

# Tham khảo: https://jupyterhub.readthedocs.io/en/1.2.1/reference/config-proxy.html

echo "map $http_upgrade \$connection_upgrade{"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "default upgrade;"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "'' close;"  >> /etc/nginx/sites-enabled/$FQDN.conf 
echo "}"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "server {"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "    listen 80;"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "    # Root directory của website"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "    root /var/www/html/;"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "    # File index mặc định"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "    index.html index.htm index.nginx-debian.html;"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "    # Tên miền hoặc IP"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo '    server_name '$FQDN';'  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "    # Cấu hình xử lý lỗi"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "    location / {"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "        try_files $uri $uri/ =404;"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "    }"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "	  location /jupyter/ {"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "    # NOTE important to also set base url"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "    # of jupyterhub to /jupyter in its config"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "    proxy_pass http://127.0.0.1:8000;"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "    proxy_redirect   off;"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "    proxy_set_header X-Real-IP $remote_addr;"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "    proxy_set_header Host \$host;"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "    proxy_set_header X-Forwarded-Proto \$scheme;"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "    # websocket headers"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "    proxy_set_header upgrade \$http_upgrade;"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "    proxy_set_header connection \$connection_upgrade;"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "    }"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "    error_log /var/log/nginx/error.log;"  >> /etc/nginx/sites-enabled/$FQDN.conf	
echo "    access_log /var/log/nginx/access.log;"  >> /etc/nginx/sites-enabled/$FQDN.conf
echo "}"  >> /etc/nginx/sites-enabled/$FQDN.conf		

sudo nginx -t
sudo systemctl restart nginx.service

# Install gdal from conda-forge.
#sudo -E conda install -c conda-forge gdal
# Install there with pip
#sudo -E pip install there
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -n -d $FQDN --email $emailcertbot --agree-tos --redirect --hsts
fi