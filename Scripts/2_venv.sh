#!/bin/bash

echo "=== !!! Выполнять под пользователем проекта (не root) !!! ==="

if [[ -z $PROJECT_USER || $USER != $PROJECT_USER ]]; then
    echo "=== Вы пользователь '$USER', необходимо перезайти под пользователем проекта: '$PROJECT_USER'! ==="
    exit
fi

echo 
read -p "=== Введите название проекта (папки): " proj_name
mkdir ~/$proj_name
cd ~/$proj_name

echo
echo "=== Установка вирт. окружения в папке $proj_name ==="
python3 -m venv venv

echo
echo "=== Активация вирт.окружения ==="
source venv/bin/activate

echo
echo "=== Копирование файлов ==="
sudo cp -R /root/Aiogram3/Scripts ./
sudo cp -R /root/Aiogram3/Service ./
sudo cp -R /root/Aiogram3/Nginx ./
sudo cp -R /root/Aiogram3/html_for_bot ./
sudo cp /root/Aiogram3/main.py ./
sudo chown -R $USER:$USER ./
sudo rm -rf /root/Aiogram3

echo
echo "=== Установка Aiogram 3.2.0 ==="
pip3 install --upgrade pip
pip install aiogram==3.2.0
pip freeze > requirements.txt

echo
read -p "=== Введите токен телеграмм бота: " bot_token
echo
read -p "=== Введите имя домена или IP адрес: " domain_name
echo
echo "=== Установка переменных окружения ===" 
echo "BOT_TOKEN='$bot_token'" | sudo tee -a /etc/environment
echo "DOMAIN_NAME='$domain_name'" | sudo tee -a /etc/environment
echo "PROJECT_NAME='$proj_name'" | sudo tee -a /etc/environment

echo
echo "=== Подготовка самоподписанного SSL сертификата для домена (IP) (Nginx) ===" 
openssl req -newkey rsa:2048 -sha256 -nodes -keyout $domain_name.key -x509 -days 365 -out $domain_name.crt -subj "/C=RU/ST=RT/L=KAZAN/O=Home/CN=$domain_name"
sudo mkdir /etc/ssl/nginx
sudo mv $domain_name.key /etc/ssl/nginx/$domain_name.key
sudo mv $domain_name.crt /etc/ssl/nginx/$domain_name.crt
mkdir ~/$PROJECT_NAME/SSL
sudo ln -s /etc/ssl/nginx/$domain_name.key ~/$PROJECT_NAME/SSL/$domain_name.key
sudo ln -s /etc/ssl/nginx/$domain_name.crt ~/$PROJECT_NAME/SSL/$domain_name.crt

echo
echo "=== Запуск сервиса (SYSTEMD) бота ===" 
echo
sudo cp /home/$USER/$proj_name/Service/Aiogram3_bot.service /lib/systemd/system/Aiogram3_bot.service
sudo systemctl daemon-reload
sudo systemctl enable Aiogram3_bot.service
sudo systemctl start Aiogram3_bot.service

#============================================

