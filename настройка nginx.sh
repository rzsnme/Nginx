#БЕЗОПАСНОСТЬ
#Меняем порт подключения по SSH
sudo nano /etc/ssh/sshd_config
#Ставим номер порта. Желательно от 5000 до 40000
port 22

sudo /etc/init.d/ssh restart


#Создаем нового пользователя
useradd zsn -m -s /bin/bash
#редактируем его права
nano /etc/sudoers
#Добавляем строку
zsn    ALL=(ALL) NOPASSWD: ALL

#Добавляем SSH ключ
su zsn
cd ~
mkdir .ssh
nano .ssh/authorized_keys
chmod 700 .ssh -R

#Переподключаемся по SSH с новым пользователем

#Отключаем пароль
sudo passwd -l zsn

#Добавляем цветовую схему
nano ~/.bashrc

force_color_prompt=yes

#Отключаем ROOT пользователя
sudo nano /etc/ssh/sshd_config

PermitRootLogin no

____________________________________________________________________
#УСТАНОВКА ПРОГРАММ
#Репозитарий
sudo nano /etc/apt/sources.list

#Копируем туда
deb http://packages.dotdeb.org wheezy all
deb-src http://packages.dotdeb.org wheezy all
deb http://packages.dotdeb.org wheezy-php55 all
deb-src http://packages.dotdeb.org wheezy-php55 all

#Устанавливаем ключи
wget http://www.dotdeb.org/dotdeb.gpg
cat dotdeb.gpg | sudo apt-key add -

sudo aptitude update
sudo aptitude upgrade
#
sudo aptitude install  mc htop
#
sudo aptitude install -y php5 php5-fpm php-pear php5-common php5-mcrypt php5-mysql php5-cli php5-gd php5-intl php5-curl php5-dev
#
sudo aptitude install -y nginx
#
sudo aptitude install -y mysql-server mysql-client mysql-common libmysqlclient18
#
sudo apt-get install -y gcc g++ make
sudo dpkg-reconfigure tzdata
sudo apt-get install fail2ban
____________________________________________________________________
#КОНФИГУРАЦИЯ
#Конфигурация сервера
sudo nano /etc/nginx/nginx.conf

user www-data;
worker_processes 1;
pid /run/nginx.pid;

events {
    worker_connections 768;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    gzip on;
    gzip_disable "msie6";

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}


#Папки и права на них
sudo mkdir -p /var/www/zsn.me
sudo chmod -R a-rwx,u+rwX,g+rX /var/www/zsn.me
sudo chown www-data:www-data -R /var/www/zsn.me
sudo find /var/www/zsn.me -type d -exec chmod 775 {} +
sudo find /var/www/zsn.me -type f -exec chmod 664 {} +



#Конфигурация сайта
sudo nano /etc/nginx/sites-available/zsn.me


upstream php5-fpm {
    server unix:/var/run/php5-fpm.sock;
}

# redirect from www to non-www
server {
  listen 80;

  server_name www.zsn.me;
  return 301 $scheme://zsn.me$request_uri;
}

server {
  listen 80;

  server_name zsn.me;
  root /var/www/zsn.me;
  client_max_body_size 256M;

  # strip index.php;/ prefix if it is present
  rewrite ^/index\.php/?(.*)$ /$1 permanent;

  location / {
    index index.php;
    try_files $uri @rewriteapp;
  }

  location @rewriteapp {
    rewrite ^(.*)$ /index.php/$1 last;
  }

  # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
  location ~ ^/(index|index)\.php(/|$) {
    fastcgi_pass   php5-fpm;
    fastcgi_split_path_info ^(.+\.php)(/.*)$;
    include fastcgi_params;
    fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
    fastcgi_param  HTTPS              off;
  }
}

sudo ln -s /etc/nginx/sites-available/zsn.me /etc/nginx/sites-enabled/zsn.me

sudo rm /etc/nginx/sites-enabled/default

sudo nano /var/www/zsn.me/index.php

#Текст
<?php
phpinfo();
?>

sudo service nginx reload

#Конфигурация PHP
sudo nano /etc/php5/fpm/php.ini

date.timezone = Europe/Amsterdam
short_open_tag = Off
expose_php = off
max_execution_time = 60
memory_limit = 256M
post_max_size = 128M
upload_max_filesize = 128M

sudo nano /etc/php5/cli/php.ini

date.timezone = Europe/Amsterdam
short_open_tag = Off

#Конфигурация mysql
sudo nano /etc/mysql/my.cnf

#Добавляем innodb_file_per_table right после [mysqld]
[mysqld]
innodb_file_per_table

sudo service mysql restart

sudo mysql_secure_installation
#ввести root пароль mysql и на все вопросы кроме первого о замене пароля отвечать да



#Node JS

wget http://nodejs.org/dist/node-latest.tar.gz
tar -zxvf node-latest.tar.gz
cd node-v*
./configure
make
sudo make install

#Installing LESS compiler

sudo npm install -g less
#Installing uglify-js

sudo npm install -g uglify-js
#GIT
sudo apt-get install -y git


