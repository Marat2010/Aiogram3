#!/bin/bash

echo "=== !!! Выполнять под пользователем проекта (не root) !!! ==="

if [[ -z $PROJECT_USER || $USER != $PROJECT_USER ]]; then
    echo "=== Вы пользователь '$USER', необходимо перезайти под пользователем проекта: '$PROJECT_USER'! ==="
    echo "=== exit, su 'PROJECT_USER', $ cd ~ ==="
    exit
fi

if [[ -z $PROJECT_NAME || -z $DOMAIN_NAME || -z $BOT_TOKEN ]]; then
    echo "=== Нет необходимых переменных окружения (PROJECT_NAME, DOMAIN_NAME, BOT_TOKEN) ! ==="
    echo "=== Необходимо перезайти под пользователем проекта: '$PROJECT_USER' (exit, su $PROJECT_USER, cd ~)! ==="
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
~/$PROJECT_NAME/Nginx/DOMAIN.sh
~/$PROJECT_NAME/Nginx/www/html/index.sh
~/$PROJECT_NAME/Nginx/www/ind/ind.sh

sudo cp ~/$PROJECT_NAME/Nginx/nginx_bot.conf /etc/nginx/sites-available/
sudo cp ~/$PROJECT_NAME/Nginx/$DOMAIN_NAME.conf /etc/nginx/sites-available/

sudo ln -s /etc/nginx/sites-available/nginx_bot.conf /etc/nginx/sites-enabled/nginx_bot
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
sudo ln -s /etc/nginx/sites-available/$DOMAIN_NAME.conf /var/www/html/$DOMAIN_NAME.txt
sudo ln -s /etc/nginx/sites-available/$DOMAIN_NAME.conf /var/www/ind/$DOMAIN_NAME.txt

read -p "=== Введите адрес электронной почты, для получения информации об обновлении сертификатов (для cron-а): " email_ssl
echo "EMAIL_SSL='$email_ssl'" | sudo tee -a /etc/environment

echo
echo "=== Запись переменных окружения в файл '.env' проекта '$PROJECT_NAME'==="
echo "BOT_TOKEN='$BOT_TOKEN'" > ~/$PROJECT_NAME/.env
echo "PROJECT_USER='$PROJECT_USER'" >> ~/$PROJECT_NAME/.env
echo "PROJECT_NAME='$PROJECT_NAME'" >> ~/$PROJECT_NAME/.env
echo "DOMAIN_IP='$DOMAIN_NAME'" >> ~/$PROJECT_NAME/.env
echo "DOMAIN_NAME='$DOMAIN_NAME'" >> ~/$PROJECT_NAME/.env
echo "EMAIL_SSL='$email_ssl'" >> ~/$PROJECT_NAME/.env
echo "" >> ~/$PROJECT_NAME/.env

echo
echo "=== Перезапуск Nginx ==="
sudo systemctl daemon-reload
sudo systemctl restart nginx.service
echo
echo "=== Для запуска 4-ого скрипта 4_cert.sh (установка сертификатов SSL 'Let's Encrypt') ==="
echo "=== 1. Необходимо убедится, что наш веб сервер, доступен по имени домена: http://$DOMAIN_NAME  ==="
echo "=== 2. Необходимо перезайти под root-ом: $ exit, $ exit, # ssh root@$DOMAIN_IP ==="

#================================

