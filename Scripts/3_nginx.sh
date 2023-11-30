#!/bin/bash

# --- Выполнять под пользователем (не root) ---

sudo apt update
echo
echo "=== Установка пакета Nginx ==="
sudo apt -y install nginx
sudo systemctl enable nginx

echo
echo "=== Настройка Nginx ==="
sudo cp ~/Aiogram3/Nginx/nginx_bot.conf /etc/nginx/sites-available/

