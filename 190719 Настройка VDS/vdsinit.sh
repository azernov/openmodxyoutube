#!/usr/bin/env bash

# Script for installation nginx, php-fpm and mysql server to VDS
# created by: ArtProg
# youtube-channel: https://youtube.com/c/OpenModx

#example: sitename
USER=""
#example: www-data
GROUP="www-data"
#example: example.com
SITENAME=""
#example: sitename
DBNAME=""
#example: sitename
DBUSER=""
#example: dh39ndYvnMk1K9
DBUSERPASSWORD=""
#example: xenial for Ubuntu 16.04
UBUNTUCODENAME=""

#Добавляем новые репозитории для пакетов системы
#Открываем файл /etc/apt/sources.list и добавляем в нем следующие строки:

echo "==================================================================================="
echo "Adding new sources to apt/sources.list"

echo "

#nginx
deb http://nginx.org/packages/ubuntu/ $UBUNTUCODENAME nginx
deb-src http://nginx.org/packages/ubuntu/ $UBUNTUCODENAME nginx

#php
deb http://ppa.launchpad.net/ondrej/php/ubuntu $UBUNTUCODENAME main
deb-src http://ppa.launchpad.net/ondrej/php/ubuntu $UBUNTUCODENAME main

#mysql-5.7
deb http://ppa.launchpad.net/ondrej/mysql-5.7/ubuntu $UBUNTUCODENAME main
deb-src http://ppa.launchpad.net/ondrej/mysql-5.7/ubuntu $UBUNTUCODENAME main" >> /etc/apt/sources.list

echo "==================================================================================="
echo "Begin update packages:"

apt-get update
apt-get dist-upgrade

echo "==================================================================================="
echo "Installing new packages:"
#Устанавливаем новые пакеты, необходимые для проекта
apt-get install nginx mysql-server-5.7 mysql-client-5.7 libmysqlclient20 ssl-cert php7.2 php7.2-common php7.2-curl php7.2-gd php7.2-imap php7.2-mysql php7.2-pspell php7.2-recode php7.2-tidy php7.2-xmlrpc php7.2-xsl php7.2-mbstring php7.2-fpm php7.2-zip php-imagick php-gettext

echo "==================================================================================="
echo "Create new user: $USER"
#Добавляем нового пользователя в систему, под которым будет работать наш проект
useradd -d /home/$USER -g $GROUP -m -s /bin/bash $USER
usermod -a -G www-data $USER
usermod -a -G sudo $USER
passwd $USER


#Конфигурирование php
#создаем новый конфиг для php-frpm

echo "==================================================================================="
echo "Configuring php-fpm"

echo "[$SITENAME]
listen = /run/php/php7.2-$USER.sock
listen.mode = 0666
user = $USER
group = $GROUP

php_admin_value[upload_tmp_dir] = /home/$USER/tmp
php_admin_value[date.timezone] = Europe/Moscow
php_admin_value[open_basedir] = /home/$USER/$SITENAME
php_admin_value[post_max_size] = 512M
php_admin_value[upload_max_filesize] = 512M
php_admin_value[cgi.fix_pathinfo] = 0
php_admin_value[short_open_tag] = On
php_admin_value[memory_limit] = 512M
php_admin_value[session.gc_probability] = 1
php_admin_value[session.gc_divisor] = 100
php_admin_value[session.gc_maxlifetime] = 28800;
php_admin_value[error_log] = /home/$USER/logs/php_errors.log;

pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 2
pm.max_spare_servers = 4" > /etc/php/7.2/fpm/pool.d/$SITENAME.conf

echo "==================================================================================="
echo "Configuring nginx"

#Конфигурирование nginx
#Открываем файл /etc/nginx/nginx.conf и в секции http дописываем:

sed '/http {/a\
    client_max_body_size 512m;' /etc/nginx/nginx.conf > /etc/nginx/nginx.conf.tmp
    
cat /etc/nginx/nginx.conf.tmp > /etc/nginx/nginx.conf
rm /etc/nginx/nginx.conf.tmp


#Для запрета обращений к сайту по IP Создаем файл /etc/nginx/conf.d/default.conf

echo "server {
    listen [::]:80;
    listen      80;
    server_name \"\";
    return      444;
}" > /etc/nginx/conf.d/00-default.conf

rm /etc/nginx/conf.d/default.conf

#Создаем файл /etc/nginx/conf.d/$SITENAME.conf (не важно, какое имя, главное - расширение .conf).
#Пишем в него следующий конфиг:

echo "upstream backend-$USER {
    server unix:/run/php/php7.2-$USER.sock;
}

server {
    listen [::]:80;
    listen 80;
    server_name $SITENAME;
    access_log /home/$USER/logs/nginx_access.log;
    error_log /home/$USER/logs/nginx_error.log;

    gzip on;
    # Минимальная длина ответа, при которой модуль будет жать, в байтах
    gzip_min_length 1000;
    # Разрешить сжатие для всех проксированных запросов
    gzip_proxied any;
    # MIME-типы которые необходимо жать
    gzip_types text/plain application/xml application/x-javascript text/javascript text/css text/json;
    # Запрещает сжатие ответа методом gzip для IE6 (старый вариант gzip_disable \"msie6\";)
    gzip_disable \"MSIE [1-6]\.(?!.*SV1)\";
    # Уровень gzip-компрессии
    gzip_comp_level 6;


    root /home/$USER/$SITENAME/www;
    index index.php;

    location ~ ^/core/.* {
        deny all;
        return 403;
    }

    location / {
        try_files \$uri \$uri/ @rewrite;
    }
    location @rewrite {
        rewrite ^/(.*)\$ /index.php?q=\$1;
    }

    location ~ \.php\$ {
    	try_files  \$uri =404;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_pass backend-$USER;
    }


    location ~* \.(jpg|jpeg|gif|png|css|js|woff|woff2|ttf|eot|zip|tgz|gz|rar|bz2|doc|xls|exe|pdf|ppt|tar|wav|bmp|rtf|swf|ico|flv|txt|docx|xlsx)\$ {
        try_files \$uri @rewrite;
        access_log off;
        expires 10d;
        break;
    }

    location ~ /\.ht {
        deny all;
    }

}" > /etc/nginx/conf.d/$SITENAME.conf



#Конфигурирование mysql
echo "Configuring mysql"

#Открываем файл /etc/mysql/mysql.conf.d/mysqld.cnf и в секции [mysqld] в конце дописываем:

echo "sql_mode=NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION" >> /etc/mysql/mysql.conf.d/mysqld.cnf

echo "==================================================================================="
echo "making some home dirs"

#cd /home/$USER
sudo -u $USER mkdir /home/$USER/tmp
sudo -u $USER mkdir /home/$USER/logs
sudo -u $USER mkdir /home/$USER/$SITENAME
sudo -u $USER mkdir /home/$USER/$SITENAME/www


echo "==================================================================================="
echo "generating ssh keys"

sudo -u $USER mkdir /home/$USER/.ssh
sudo -u $USER chmod 755 /home/$USER/.ssh
#sudo -u $USER ssh-keygen

echo "==================================================================================="
echo "restart services"

sudo service php7.2-fpm restart
sudo service nginx restart
sudo service mysql restart

echo "==================================================================================="
echo "now you must login from user $USER"