#!/bin/bash
echo 'chon ten subdomain muon cai dat: VD: web1 => web1.demo.com'
read subdomain

#xoa file va thuc muc da co
rm -rf $subdomain
rm -rf ./www/$subdomain
rm -f nginx/conf.d/$subdomain.conf

mkdir $subdomain
mkdir $subdomain/conf.d
mkdir ./www/$subdomain

echo "server {
    listen       80;
    server_name  $subdomain.demo.com;
    location / {
        proxy_pass   http://$subdomain;
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}" > nginx/conf.d/$subdomain.conf

echo "server {
    listen 80;
    listen 443 ssl;
    server_name $subdomain.demo.com;
    root /var/www/$subdomain;
    index index.html index.htm index.php;
    charset utf-8;
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }
    access_log off;
    error_log  /var/log/nginx/default.log error;
    sendfile off;
    client_max_body_size 100m;
    location ~ \.php\$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass php-fpm:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT \$realpath_root;
    }
    location ~ /\.ht {
        deny all;
    }
}" > $subdomain/conf.d/default.conf

echo "
  $subdomain:
    image: nginx
    volumes:
      - E:/docker/multisite/$subdomain/conf.d/:/etc/nginx/conf.d
      - E:/docker/multisite/www/$subdomain/:/var/www/$subdomain
    links:
      - php-fpm" >> docker-compose.yml


echo 'chon giao dien cho website cua ban: '
read themeName

echo '============== Information =============='
echo 'subdomain: '$subdomain
echo 'themeName: '$themeName
echo '========================================='

#copy file to subfolder and unzip
cp ./theme/$themeName.zip ./www/$subdomain
cd ./www/$subdomain
unzip $themeName.zip
rm -f $themeName.zip
cd ../..

#stop and start docker
#docker-compose stop nginx
#docker-compose rm nginx
#docker rmi multisite_nginx

docker-compose up -d
docker-compose restart nginx