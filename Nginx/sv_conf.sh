#!/bin/bash

echo "server {
    listen 443 ssl;
    listen [::]:443 ssl default_server;

    ssl_certificate       /etc/ssl/nginx/$DOMAIN_NAME.crt;
    ssl_certificate_key   /etc/ssl/nginx/$DOMAIN_NAME.key;

    server_name localhost 127.0.0.1 $DOMAIN_NAME;

    root /var/www/html;

    location / {
    }

    location /ind/ {
        root /var/www;
        index ind.html;
    }
}
"> ~/$PROJECT_NAME/Nginx/sv.conf

