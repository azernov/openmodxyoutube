# Обновляем пакеты системы
apt-get update
apt-get upgrade

# Говорим про apt-cache search xxxxx

# Установка без указания версии php (можно явно указать у отдельных пакетов php7.4)
apt install nginx php-common php-cli php-curl php-json php-gd php-mysql php-xml php-zip php-fpm php-mbstring php-bcmath php-pear

# Ставим mariadb (он же в прошлом mysql)
apt install mariadb-server-10.3