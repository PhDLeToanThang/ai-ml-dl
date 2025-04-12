#!/bin/bash
########################
# Moodle 4.0.5 = Moodle v4.5
# PHP 8.3
# NGINX 1.26.2, phpmyadmin 5.2.1
# mysql 10.11.8-mariaDB-0ubuntu0.24.04.1
# OS ubuntu 24.04 LTS 
########################

############### Tham số cần thay đổi ở đây ###################
echo "FQDN: e.g: demo.company.vn"   # Đổi địa chỉ web thứ nhất Website Master for Resource code - để tạo cùng 1 Source code duy nhất 
read -e FQDN
echo "dbname: e.g: demodata"   # Tên DBNane
read -e dbname
echo "dbuser: e.g: userdata"   # Tên User access DB lmsatcuser
read -e dbuser
echo "Database Password: e.g: P@$$w0rd-1.22"
read -s dbpass
echo "phpmyadmin folder name: e.g: phpmyadmin"   # Đổi tên thư mục phpmyadmin khi add link symbol vào Website 
read -e phpmyadmin
echo "Moodle Folder Data: e.g: moodledata"   # Tên Thư mục chưa Data vs Cache
read -e FOLDERDATA
echo "dbtype name: e.g: mariadb"   # Tên kiểu Database
read -e dbtype
echo "dbhost name: e.g: localhost"   # Tên Db host connector
read -e dbhost
echo "Your Email address fro Certbot e.g: thang@company.vn" # Địa chỉ email của bạn để quản lý CA
read -e emailcertbot
GitMoodleversion="MOODLE_405_STABLE"

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

#Step 2. Install MariaDB/MySQL
#Run the following commands to install MariaDB database for Moode. You may also use MySQL instead.
sudo apt-get install mariadb-server mariadb-client -y

#Like NGINX, we will run the following commands to enable MariaDB to autostart during reboot, and also start now.
sudo systemctl stop mysql.service 
sudo systemctl start mysql.service 
sudo systemctl enable mysql.service

#Run the following command to secure MariaDB installation.
#password mysql mariadb , i'm fixed: M@tKh@uS3cr3t  --> you must changit. 

sudo mysql_secure_installation  <<EOF
n
M@tKh@uS3cr3t
M@tKh@uS3cr3t
y
n
y
y
EOF
#You will see the following prompts asking to allow/disallow different type of logins. Enter Y as shown.
# Enter current password for root (enter for none): Just press the Enter
# Set root password? [Y/n]: Y
# New password: Enter password
# Re-enter new password: Repeat password
# Remove anonymous users? [Y/n]: Y
# Disallow root login remotely? [Y/n]: N
# Remove test database and access to it? [Y/n]:  Y
# Reload privilege tables now? [Y/n]:  Y
# After you enter response for these questions, your MariaDB installation will be secured.

#Step 3. Install PHP-FPM & Related modules
sudo apt-get install software-properties-common -y
sudo -S add-apt-repository ppa:ondrej/php -y
sudo apt update -y
sudo apt install php8.3-fpm php8.3-common php8.3-mbstring php8.3-xmlrpc php8.3-soap php8.3-gd php8.3-xml php8.3-intl php8.3-mysql php8.3-cli php8.3-mcrypt php8.3-ldap php8.3-zip php8.3-curl -y

#Open PHP-FPM config file.

#sudo nano /etc/php/8.3/fpm/php.ini
#Add/Update the values as shown. You may change it as per your requirement.
cat > /etc/php/8.3/fpm/php.ini <<END
[PHP]
engine = On
short_open_tag = Off
precision = 14
output_buffering = 4096
zlib.output_compression = Off
implicit_flush = Off
unserialize_callback_func =
serialize_precision = -1
disable_functions = 
disable_classes =
zend.enable_gc = On
zend.exception_ignore_args = On
zend.exception_string_param_max_len = 0
expose_php = Off
file_uploads = On 
allow_url_fopen = On 
memory_limit = 1200M 
upload_max_filesize = 4096M
max_execution_time = 360 
cgi.fix_pathinfo = 0 
max_input_time = 60
max_input_nesting_level = 64
max_input_vars = 5000
post_max_size = 4096M
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
display_errors = Off
display_startup_errors = Off
log_errors = On
ignore_repeated_errors = Off
ignore_repeated_source = Off
report_memleaks = On
variables_order = "GPCS"
request_order = "GP"
register_argc_argv = Off
auto_globals_jit = On
auto_prepend_file =
auto_append_file =
default_mimetype = "text/html"
default_charset = "UTF-8"
doc_root =
user_dir =
enable_dl = Off
allow_url_fopen = On
allow_url_include = Off
default_socket_timeout = 60
extension=bz2
extension=curl
;extension=ffi
;extension=ftp
extension=fileinfo
;extension=gd
;extension=gettext
;extension=gmp
extension=intl
;extension=imap
extension=php_ldap.so
extension=mbstring
;extension=exif      ; Must be after mbstring as it depends on it
;extension=mysqli
;extension=oci8_12c  ; Use with Oracle Database 12c Instant Client
;extension=oci8_19  ; Use with Oracle Database 19 Instant Client
;extension=odbc
extension=openssl
;extension=pdo_firebird
;extension=pdo_mysql
;extension=pdo_oci
;extension=pdo_odbc
;extension=pdo_pgsql
;extension=pdo_sqlite
;extension=pgsql
;extension=shmop
;extension=snmp
;extension=soap
;extension=sockets
;extension=sodium
;extension=sqlite3
;extension=tidy
;extension=xsl
;zend_extension=opcache
[CLI Server]
cli_server.color = On

[Date]
date.timezone=Asia/Ho_Chi_Minh

; https://php.net/date.default-latitude
;date.default_latitude = 31.7667

; https://php.net/date.default-longitude
;date.default_longitude = 35.2333


[filter]

[iconv]

[imap]

[intl]

[sqlite3]

[Pcre]

[Pdo]

[Pdo_mysql]
pdo_mysql.default_socket=

[Phar]

[mail function]
SMTP = localhost
; https://php.net/smtp-port
smtp_port = 25
;sendmail_from = me@example.com
;sendmail_path =
;mail.force_extra_parameters =
mail.add_x_header = Off
;mail.log = syslog

[ODBC]
odbc.allow_persistent = On
odbc.check_persistent = On
odbc.max_persistent = -1
odbc.max_links = -1
odbc.defaultlrl = 4096
odbc.defaultbinmode = 1

[MySQLi]
mysqli.max_persistent = -1
mysqli.allow_persistent = On
mysqli.max_links = -1
mysqli.default_port = 3306
mysqli.default_socket =
mysqli.default_host =
mysqli.default_user =
mysqli.default_pw =
mysqli.reconnect = Off

[mysqlnd]
mysqlnd.collect_statistics = On
mysqlnd.collect_memory_statistics = Off

[OCI8]

[PostgreSQL]
pgsql.allow_persistent = On
pgsql.auto_reset_persistent = Off
pgsql.max_persistent = -1
pgsql.max_links = -1
pgsql.ignore_notice = 0
pgsql.log_notice = 0

[bcmath]
bcmath.scale = 0

[browscap]

[Session]
session.save_handler = files
session.use_strict_mode = 0
session.use_cookies = 1
session.use_only_cookies = 1
session.name = PHPSESSID
session.auto_start = 0
session.cookie_lifetime = 0
session.cookie_path = /
session.cookie_domain =
session.cookie_httponly = on
session.cookie_secure = on
session.cookie_samesite = Lax
session.serialize_handler = php
session.gc_probability = 0
session.gc_divisor = 1000
session.gc_maxlifetime = 1440
session.referer_check =
session.cache_limiter = nocache
session.cache_expire = 180
session.use_trans_sid = 0
session.sid_length = 26
session.trans_sid_tags = "a=href,area=href,frame=src,form="
session.sid_bits_per_character = 5

[Assertion]
zend.assertions = -1

[COM]

[mbstring]

[gd]

[exif]

[Tidy]
tidy.clean_output = Off

[soap]
soap.wsdl_cache_enabled=1
soap.wsdl_cache_dir="/tmp"
soap.wsdl_cache_ttl=86400
soap.wsdl_cache_limit = 5

[sysvshm]

[ldap]
ldap.max_links = -1

[dba]

[opcache]

[curl]

[openssl]

[ffi]
END

systemctl restart php8.3-fpm.service


#Step 4. Create Moodle Database
#Log into MySQL and create database for Moodle.

# install tool mysql-workbench-community from Tonin Bolzan (tonybolzan)
sudo snap install mysql-workbench-community

mysql -uroot -prootpassword -e "DROP DATABASE IF EXISTS ${dbname};"
mysql -uroot -prootpassword -e "CREATE DATABASE IF NOT EXISTS ${dbname} CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
mysql -uroot -prootpassword -e "CREATE USER IF NOT EXISTS '${dbuser}'@'${dbhost}' IDENTIFIED BY "${dbpass}";"
mysql -uroot -prootpassword -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${dbuser}'@'${dbhost}';"
mysql -uroot -prootpassword -e "GRANT SELECT ON mysql.time_zone_name TO '${dbuser}'@'${dbhost}';"
mysql -uroot -prootpassword -e "FLUSH PRIVILEGES;"
mysql -uroot -prootpassword -e "SHOW DATABASES;"

# Nếu đã có thì bỏ qua đoạn hàm này như thế nào ?
#Step 5. Next, edit the MariaDB default configuration file and define the innodb_file_format:
#nano /etc/mysql/mariadb.conf.d/50-server.cnf
#Add the following lines inside the [mysqld] section: 
# if new php.ini configure then clear sign sharp # comment
cat > /etc/mysql/mariadb.conf.d/50-server.cnf <<END
[mysqld]
innodb_file_format = Barracuda
innodb_file_per_table = 1
innodb_large_prefix = ON
max_allowed_packet=128M

[server]
default-time-zone=+7:00

END

#Save the file then restart the MariaDB service to apply the changes.
systemctl restart mariadb

#Step 6. Download & Install ITIL
#We will be using Git to install/update the ITIL Core Application 
sudo apt install git -y

cd /opt
#Run the following command to download Moodle package.
#Download the Moodle Code and Index
sudo git clone git://git.moodle.org/moodle.git
#Change directory into the downloaded Moodle folder
cd moodle
#Retrieve a list of each branch available
#sudo git branch -a
#Tell git which branch to track or use
#sudo git branch --track $GitMoodleversion origin/$GitMoodleversion

#if get error
git fetch
#Finally, Check out the Moodle version specified
sudo git checkout $GitMoodleversion
#Run the following command to extract package to NGINX website root folder.
sudo cp -R /opt/moodle /var/www/html/$FQDN
sudo mkdir /var/www/html/$FOLDERDATA
#Change the folder permissions.
sudo chown -R www-data:www-data /var/www/html/$FQDN/
sudo chmod -R 755 /var/www/html/$FQDN/
sudo chown www-data /var/www/html/$FOLDERDATA

#Once the download is completed, edit the Moodle config.php and define the database type: 
#cp /var/www/html/$FQDN/config-dist.php /var/www/html/$FQDN/config.php
#set database details with perl find and replace
echo "<?php"  >> /var/www/html/$FQDN/config.php
echo 'unset($CFG);' >> /var/www/html/$FQDN/config.php
echo 'global $CFG;' >> /var/www/html/$FQDN/config.php
echo '$CFG= new stdClass();' >> /var/www/html/$FQDN/config.php
echo '$CFG->dbtype    = "'"$dbtype"'";' >> /var/www/html/$FQDN/config.php
echo '$CFG->dblibrary = "'"native"'";' >> /var/www/html/$FQDN/config.php
echo '$CFG->dbhost    = "'"$dbhost"'";' >> /var/www/html/$FQDN/config.php
echo '$CFG->dbname    = "'"$dbname"'";' >> /var/www/html/$FQDN/config.php
echo '$CFG->dbuser    = "'"$dbuser"'";' >> /var/www/html/$FQDN/config.php
echo '$CFG->dbpass    = "'"$dbpass"'";' >> /var/www/html/$FQDN/config.php
echo '$CFG->prefix    = "'"mdl_"'";' >> /var/www/html/$FQDN/config.php
echo '$CFG->dboptions = array(' >> /var/www/html/$FQDN/config.php
echo "'dbpersist' => false," >> /var/www/html/$FQDN/config.php
echo "'dbsocket'  => false," >> /var/www/html/$FQDN/config.php
echo "'dbport' => '',"  >> /var/www/html/$FQDN/config.php
echo "'dbhandlesoptions' => false,"  >> /var/www/html/$FQDN/config.php
echo "'dbcollation' => 'utf8mb4_unicode_ci'," >> /var/www/html/$FQDN/config.php
echo ");" >> /var/www/html/$FQDN/config.php
echo '$CFG->wwwroot   = "'"https://$FQDN"'";' >> /var/www/html/$FQDN/config.php
echo '$CFG->dataroot  = "'"/var/www/html/$FOLDERDATA"'";' >> /var/www/html/$FQDN/config.php
echo '$CFG->directorypermissions = 02777;' >> /var/www/html/$FQDN/config.php
echo '$CFG->admin = "'"admin"'";' >> /var/www/html/$FQDN/config.php
echo "require_once(__DIR__ . '/lib/setup.php');" >> /var/www/html/$FQDN/config.php

#Step 7. Configure NGINX
#Them dong lenh xoa noi dung cau hinh trong file conf truoc khi dien thong tin chuan moi:
cat > /etc/nginx/conf.d/${FQDN}.conf <<END
END
#Next, you will need to create an Nginx virtual host configuration file to host Moodle:
#$ nano /etc/nginx/conf.d/$FQDN.conf

echo 'server {'  >> /etc/nginx/conf.d/$FQDN.conf
echo '    listen 80;' >> /etc/nginx/conf.d/$FQDN.conf
echo '    root /var/www/html/'$FQDN';'>> /etc/nginx/conf.d/$FQDN.conf
echo '    index  index.php index.html index.htm;'>> /etc/nginx/conf.d/$FQDN.conf
echo '    server_name '$FQDN';'>> /etc/nginx/conf.d/$FQDN.conf
echo '    client_max_body_size 512M;'>> /etc/nginx/conf.d/$FQDN.conf
echo '    autoindex off;'>> /etc/nginx/conf.d/$FQDN.conf
echo '    location / {'>> /etc/nginx/conf.d/$FQDN.conf
echo '        try_files $uri $uri/ =404;'>> /etc/nginx/conf.d/$FQDN.conf
echo '    }'>> /etc/nginx/conf.d/$FQDN.conf
echo '    location /dataroot/ {'>> /etc/nginx/conf.d/$FQDN.conf
echo '      internal;'>> /etc/nginx/conf.d/$FQDN.conf
echo '      alias /var/www/html/'$FOLDERDATA'/;'>> /etc/nginx/conf.d/$FQDN.conf
echo '    }'>> /etc/nginx/conf.d/$FQDN.conf
echo '    location ~ [^/].php(/|$) {'>> /etc/nginx/conf.d/$FQDN.conf
echo '        include snippets/fastcgi-php.conf;'>> /etc/nginx/conf.d/$FQDN.conf
echo '        fastcgi_pass unix:/run/php/php8.3-fpm.sock;'>> /etc/nginx/conf.d/$FQDN.conf
echo '        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;'>> /etc/nginx/conf.d/$FQDN.conf
echo '        include fastcgi_params;'>> /etc/nginx/conf.d/$FQDN.conf
echo '    }'>> /etc/nginx/conf.d/$FQDN.conf
echo '	location ~ ^/(doc|sql|setup)/{'>> /etc/nginx/conf.d/$FQDN.conf
echo '		deny all;'>> /etc/nginx/conf.d/$FQDN.conf
echo '	}'>> /etc/nginx/conf.d/$FQDN.conf
echo '}'>> /etc/nginx/conf.d/$FQDN.conf

#Save and close the file then verify the Nginx for any syntax error with the following command: 
nginx -t

#8. Setup and Configure PhpMyAdmin
sudo apt update -y
sudo apt install phpmyadmin -y

#9. gỡ bỏ apache:
sudo service apache2 stop
sudo apt-get purge apache2 apache2-utils apache2.2-bin apache2-common
sudo apt-get purge apache2 apache2-utils apache2-bin apache2.2-common

sudo apt-get autoremove
whereis apache2
apache2: /etc/apache2
sudo rm -rf /etc/apache2

sudo ln -s /usr/share/phpmyadmin /var/www/html/$FQDN/$phpmyadmin
sudo chown -R root:root /var/lib/phpmyadmin
sudo nginx -t

#10. Nâng cấp PhpmyAdmin lên version 5.2.1:
sudo mv /usr/share/phpmyadmin/ /usr/share/phpmyadmin.bak
sudo mkdir /usr/share/phpmyadmin/
cd /usr/share/phpmyadmin/
sudo wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.tar.gz
sudo tar xzf phpMyAdmin-5.2.1-all-languages.tar.gz
#Once extracted, list folder.
ls
#You should see a new folder phpMyAdmin-5.2.1-all-languages
#We want to move the contents of this folder to /usr/share/phpmyadmin
sudo mv phpMyAdmin-5.2.1-all-languages/* /usr/share/phpmyadmin
ls /usr/share/phpmyadmin
mkdir /usr/share/phpMyAdmin/tmp   # tạo thư mục cache cho phpmyadmin

sudo systemctl restart nginx
systemctl restart php8.3-fpm.service

#11. Install Certbot
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -n -d $FQDN --email $emailcertbot --agree-tos --redirect --hsts

# You should test your configuration at:
# https://www.ssllabs.com/ssltest/analyze.html?d=$FQDN
#/etc/letsencrypt/live/$FQDN/fullchain.pem
#   Your key file has been saved at:
#   /etc/letsencrypt/live/$FQDN/privkey.pem
#   Your cert will expire on yyyy-mm-dd. To obtain a new or tweaked
#   version of this certificate in the future, simply run certbot again
#   with the certonly option. To non-interactively renew *all* of
#   your certificates, run certbot renew
fi
