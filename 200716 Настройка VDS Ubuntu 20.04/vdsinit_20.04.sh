#!/usr/bin/env bash

# Script for installation nginx, php-fpm and mysql server to VDS
# created by: ArtProg
# youtube-channel: https://youtube.com/c/OpenModx

#example: sitename
USER="test"
#example: www-data
GROUP="www-data"
#example: example.com
SITENAME="test.site"
#example: sitename
DBNAME="test"
#example: sitename
DBUSER="test"
#example: dh39ndYvnMk1K9
DBUSERPASSWORD="testtest"


# Обновляем пакеты системы
apt-get update
apt-get upgrade

# Говорим про apt-cache search xxxxx

# Установка без указания версии php (можно явно указать у отдельных пакетов php7.4)
apt install nginx php-common php-cli php-curl php-json php-gd php-mysql php-xml php-zip php-fpm php-mbstring php-bcmath php-pear

# Ставим mariadb (он же в прошлом mysql)
apt install mariadb-server-10.3



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
listen = /run/php/php-$USER.sock
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
pm.max_spare_servers = 4" > /etc/php/7.4/fpm/pool.d/$SITENAME.conf

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
}" > /etc/nginx/sites-available/00-default.conf

rm /etc/nginx/sites-available/default.conf
rm /etc/nginx/sites-enabled/default.conf

ln -s /etc/nginx/sites-available/00-default.conf /etc/nginx/sites-enabled/00-default.conf

#Создаем файл /etc/nginx/conf.d/$SITENAME.conf (не важно, какое имя, главное - расширение .conf).
#Пишем в него следующий конфиг:

echo "upstream backend-$USER {
    server unix:/run/php/php-$USER.sock;
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

}" > /etc/nginx/sites-available/01-$SITENAME.conf

ln -s /etc/nginx/sites-available/01-$SITENAME.conf /etc/nginx/sites-enabled/01-$SITENAME.conf


#Конфигурирование mysql
echo "Configuring mysql"

#Открываем файл /etc/mysql/my.cnf и в секции [mysqld] в конце дописываем:

echo "[mysqld]
sql_mode=NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION" >> /etc/mysql/my.cnf

# Чтобы создать пользователя и БД: Выполнить под root-пользователем mysql
# CREATE DATABASE IF NOT EXISTS $DBNAME;
# CREATE USER '$DBUSER'@'localhost' IDENTIFIED BY '$DBUSERPASSWORD';
# GRANT USAGE ON *.* TO '$DBUSER'@'localhost' IDENTIFIED BY '$DBUSERPASSWORD' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;
# GRANT ALL PRIVILEGES ON `$DBNAME`.* TO '$DBUSERE'@'localhost' WITH GRANT OPTION;
# FLUSH PRIVILEGES;




echo "==================================================================================="
echo "making some home dirs"

sudo -u $USER mkdir /home/$USER/tmp
sudo -u $USER mkdir /home/$USER/logs
sudo -u $USER mkdir /home/$USER/$SITENAME
sudo -u $USER mkdir /home/$USER/$SITENAME/www


echo "==================================================================================="
echo "generating ssh keys"

sudo -u $USER mkdir /home/$USER/.ssh
sudo -u $USER chmod 755 /home/$USER/.ssh
# sudo -u $USER ssh-keygen

echo "==================================================================================="
echo "restart services"

sudo service php7.4-fpm restart
sudo service nginx restart
sudo service mysql restart

echo "==================================================================================="
echo "now you must login from user $USER"