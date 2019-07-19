[example.my]
listen = /run/php/php7.2-website.sock
listen.mode = 0666
user = website
group = www-data

php_admin_value[upload_tmp_dir] = /home/website/example.my/tmp
php_admin_value[date.timezone] = Europe/Moscow
php_admin_value[open_basedir] = /home/website/example.my
php_admin_value[post_max_size] = 512M
php_admin_value[upload_max_filesize] = 512M
php_admin_value[cgi.fix_pathinfo] = 0
php_admin_value[short_open_tag] = On
php_admin_value[memory_limit] = 512M
php_admin_value[session.gc_probability] = 1
php_admin_value[session.gc_divisor] = 100
php_admin_value[session.gc_maxlifetime] = 28800;
php_admin_value[error_log] = /home/website/logs/php_errors.log;

pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 2
pm.max_spare_servers = 4