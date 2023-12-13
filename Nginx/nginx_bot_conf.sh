#!/bin/bash

echo "server {
    listen 8443 ssl;
    listen [::]:8443 ssl;

    ssl_certificate       /etc/ssl/nginx/$DOMAIN_NAME.crt;
    ssl_certificate_key   /etc/ssl/nginx/$DOMAIN_NAME.key;

    server_name $DOMAIN_NAME;

    location / {
        root /home/$PROJECT_USER/$PROJECT_NAME/html_for_bot;
        index bot.html;
    }

    location /$PROJECT_NAME {
        root /home/$PROJECT_USER;

        proxy_set_header Host \$http_host;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_redirect off;
        proxy_buffering off;
        proxy_pass http://127.0.0.1:8080;
    }
}
" > ~/$PROJECT_NAME/Nginx/nginx_bot.conf

