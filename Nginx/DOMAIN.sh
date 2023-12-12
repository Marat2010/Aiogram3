#!/bin/bash

echo "server {
    listen 80;

#    ssl_certificate       /etc/ssl/nginx/$DOMAIN_NAME.crt;
#    ssl_certificate_key   /etc/ssl/nginx/$DOMAIN_NAME.key;

    server_name $DOMAIN_NAME;

    root /var/www/html;

    location / {
    }
}
"> ~/$PROJECT_NAME/Nginx/$DOMAIN_NAME.conf

