#!/bin/bash

echo "=== !!! Выполнять под пользователем проекта (не root) !!! ==="

if [[ -z $PROJECT_USER || $USER != $PROJECT_USER ]]; then
    echo "=== Вы пользователь '$USER', необходимо перезайти под пользователем проекта: '$PROJECT_USER'! ==="
    exit
fi

sudo apt update
echo
echo "=== Установка пакета Nginx ==="
sudo apt -y install nginx
sudo systemctl enable nginx

echo
echo "=== Настройка Nginx ==="
chmod +x ~/$PROJECT_NAME/Nginx/*
~/$PROJECT_NAME/Nginx/nginx_bot_conf.sh
~/$PROJECT_NAME/Nginx/sv_conf.sh
~/$PROJECT_NAME/Nginx/DOMAIN.sh

sudo cp ~/$PROJECT_NAME/Nginx/nginx_bot.conf /etc/nginx/sites-available/
sudo cp ~/$PROJECT_NAME/Nginx/sv.conf /etc/nginx/sites-available/
sudo cp ~/$PROJECT_NAME/Nginx/$DOMAIN_NAME.conf /etc/nginx/sites-available/

sudo ln -s /etc/nginx/sites-available/nginx_bot.conf /etc/nginx/sites-enabled/nginx_bot
sudo ln -s /etc/nginx/sites-available/sv.conf /etc/nginx/sites-enabled/sv
sudo ln -s /etc/nginx/sites-available/$DOMAIN_NAME.conf /etc/nginx/sites-enabled/$DOMAIN_NAME.conf
#sudo rm -f /etc/nginx/sites-enabled/default

echo
echo "=== Копирование примеров страниц сайта ===" 
sudo cp -R ~/$PROJECT_NAME/Nginx/www/* /var/www/

echo
echo "=== Открытие доступа для веб в папку проекта /home/... ==="
echo "(добавления пользователя 'www-data' в группу пользователя проекта '$PROJECT_USER')"
sudo usermod -aG $PROJECT_USER www-data 

# ---- iframe для html страниц, для показа конфигурации Nginx --------
sudo ln -s /etc/nginx/sites-available/nginx_bot.conf ~/$PROJECT_NAME/html_for_bot/nginx_bot_conf.txt
sudo ln -s /etc/nginx/sites-available/sv.conf /var/www/html/sv_conf.txt
sudo ln -s /etc/nginx/sites-available/sv.conf /var/www/ind/sv_conf.txt

read -p "=== Введите адрес электронной почты, для получения информации об обновлении сертификатов (для cron-а): " email_ssl
echo "EMAIL_SSL='$email_ssl'" | sudo tee -a /etc/environment

echo
echo "=== Перезапуск Nginx ==="
sudo systemctl daemon-reload
sudo systemctl restart nginx.service

echo "=== Необходимо перезайти под root-ом: $ exit, $ exit, # ssh root@xxx.xxx.xxx.xxx ==="

#================================

