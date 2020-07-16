useradd -d /home/test -g $GROUP -m -s /bin/bash $USER
usermod -a -G www-data $USER
usermod -a -G sudo $USER
passwd test
