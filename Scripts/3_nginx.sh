#!/bin/bash

# --- Выполнять под пользователем проекта (не root) ---

sudo apt update
echo
echo "=== Установка пакета Nginx ==="
sudo apt -y install nginx
sudo systemctl enable nginx

echo
echo "=== Настройка Nginx ==="
sudo cp ~/$PROJECT_NAME/Nginx/nginx_bot.conf /etc/nginx/sites-available/
sudo cp ~/$PROJECT_NAME/Nginx/sv.conf /etc/nginx/sites-available/

echo
echo "=== Подготовка SSL сертификата ===" 
echo
read -p "=== Введите имя домена или IP адрес: " domain_name
echo "=== Установка переменных окружения ===" 
echo "DOMAIN_NAME='$domain_name'" | sudo tee -a /etc/environment

sudo mkcert -install $domain_name
sudo mkdir /etc/ssl/nginx
sudo mv  $domain_name-key.pem /etc/ssl/nginx/$domain_name.key
sudo mv  $domain_name.pem /etc/ssl/nginx/$domain_name.crt
mkdir ~/$PROJECT_NAME/SSL
sudo ln -s /etc/ssl/nginx/$domain_name.key ~/$PROJECT_NAME/SSL/$domain_name.key
sudo ln -s /etc/ssl/nginx/$domain_name.crt ~/$PROJECT_NAME/SSL/$domain_name.crt

echo
echo "=== Копирование примеров страниц сайта ===" 
sudo cp -R ~/$PROJECT_NAME/Nginx/www/* /var/www/

echo
echo "=== Перезапуск Nginx ==="
sudo systemctl restart nginx




