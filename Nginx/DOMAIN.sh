#!/bin/bash

echo "server {
    listen 80;

    server_name $DOMAIN_NAME;

    root /var/www/html;

    location / {
    }
}
"> ~/$PROJECT_NAME/Nginx/$DOMAIN_NAME.conf

