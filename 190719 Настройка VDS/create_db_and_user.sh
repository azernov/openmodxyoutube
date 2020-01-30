#!/usr/bin/env bash

# скрипт создает БД и пользователя. Требует ввода пароля от root-пользователя mysql
# Вам необходимо указать 3 переменных ниже
#example: sitename
DBNAME=""
#example: sitename
DBUSER=""
#example: dh39ndDoqDMk1K9
DBUSERPASSWORD=""

mysql -u root -p -Bse "CREATE DATABASE IF NOT EXISTS \`$DBNAME\` CHARACTER SET utf8 COLLATE utf8_general_ci;\
CREATE USER '$DBUSER'@'localhost' IDENTIFIED BY '$DBUSERPASSWORD';\
GRANT USAGE ON *.* TO '$DBUSER'@'localhost' IDENTIFIED BY '$DBUSERPASSWORD' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;\
GRANT ALL PRIVILEGES ON \`$DBNAME\`.* TO '$DBUSER'@'localhost' WITH GRANT OPTION;\
FLUSH PRIVILEGES;"
