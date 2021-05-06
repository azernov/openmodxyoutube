Скрипт для непрямого доступа к файлам/материалам курса

Используется для проверки авторизации пользователя при доступе к защищенному каталогу

Данный файл должен находиться в каталоге [путь до веб-директории]/assets/components/[имя_вашего_компонента]/

Для корректной работы необходимо также внести изменения в конфигурацию веб-сервера, чтобы
любые запросы к защищенному каталогу проходили через указанный скрипт.

Например, для nginx это может выглядеть так:

```
server {
    listen               80;
    server_name          yourdomain.com;

    root                 "/your/path/to/www/dir";

    access_log           /your/path/to/nginx_access.log;
    error_log            /your/path/to/nginx_error.log;
    
    index                index.php;
    
    location /core/ {                                                                                                                                                                                                                               
        deny all;                                                                                                                                                                                                                                                    
    }
    

    # НАЧАЛО ДОП. КОНФИГУРАЦИИ ДЛЯ ЗАЩИЩЕННОГО КАТАЛОГА
    # В нашем случае это каталог assets/authfiles/
    
    # auth files rewrite
    location ~ "^/assets/authfiles/" {
        rewrite "^/assets/authfiles/(.*)$" /assets/components/yourcomponentname/getauthfile.php?file=$1;
    }

    # КОНЕЦ ДОП. КОНФИГУРАЦИИ ДЛЯ ЗАЩИЩЕННОГО КАТАЛОГА
    
    location / {
        try_files $uri $uri/ @rewrite;
    }
    
    location @rewrite {
        rewrite            ^/(.*)$ /index.php?q=$1;
    }

    location ~ \.php$ {
        fastcgi_pass     unix:/your/path/to/php-fpm.sock;
        fastcgi_param    SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include          fastcgi_params;
    }

    location ~* ^.+\.(jpg|jpeg|gif|css|png|js|ico|bmp|woff|ttf|svg|woff2|xls|doc|xlsx|docx|ppt)$ {
       access_log       off;
       expires          10d;
       break;
    }
    
    location ~ /\.ht {
        deny            all;
    }
}
```
