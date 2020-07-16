# подготовка каталогов, которые мы использовали в настройках
sudo -u test mkdir /home/test/tmp
sudo -u test mkdir /home/test/logs
sudo -u test mkdir /home/test/test.site
sudo -u test mkdir /home/test/test.site/www


# генерация ssh ключей
sudo -u test mkdir /home/test/.ssh
sudo -u test chmod 755 /home/test/.ssh
# sudo -u test ssh-keygen

# перезапуск сервисов
sudo service php7.4-fpm restart
sudo service nginx restart
sudo service mysql restart