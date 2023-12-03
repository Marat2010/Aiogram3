#!/bin/bash

# --- Выполнять под пользователем (не root) ---

sudo apt update
echo
echo "=== Установка пакета Nginx ==="
sudo apt -y install nginx
sudo systemctl enable nginx

echo
echo "=== Настройка Nginx ==="
sudo cp ~/$PROJECT_NAME/Nginx/nginx_bot.conf /etc/nginx/sites-available/
sudo cp ~/$PROJECT_NAME/Nginx/sv.conf /etc/nginx/sites-available/

sudo mkdir /etc/ssl/nginx
sudo cp  ~/$PROJECT_NAME/SSL/$DOMAIN_NAME.key /etc/ssl/nginx/
sudo cp  ~/$PROJECT_NAME/SSL/$DOMAIN_NAME.crt /etc/ssl/nginx/

