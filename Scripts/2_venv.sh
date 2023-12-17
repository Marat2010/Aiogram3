#!/bin/bash

echo "=== !!! Выполнять под пользователем проекта (не root) !!! ==="

if [[ -z $PROJECT_USER || $USER != $PROJECT_USER ]]; then
    echo "=== Вы пользователь '$USER', необходимо перезайти под пользователем проекта: 'PROJECT_USER'! ==="
    echo "=== # su 'PROJECT_USER', $ cd ~ ==="
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
#sudo rm -rf /root/Aiogram3

echo
echo "=== Установка Aiogram 3.2.0 ==="
pip3 install --upgrade pip
pip install aiogram==3.2.0
#pip install python-dotenv==1.0.0
pip freeze > requirements.txt

echo
read -p "=== Введите токен телеграмм бота: " bot_token
echo
read -p "=== Введите IP адрес сервера VPS: " domain_ip
echo
read -p "=== Введите имя домена сервера VPS: " domain_name
echo
echo "=== Установка переменных окружения ===" 
echo "BOT_TOKEN='$bot_token'" | sudo tee -a /etc/environment
echo "DOMAIN_IP='$domain_ip'" | sudo tee -a /etc/environment
echo "DOMAIN_NAME='$domain_name'" | sudo tee -a /etc/environment
echo "PROJECT_NAME='$proj_name'" | sudo tee -a /etc/environment

echo
echo "=== Подготовка самоподписанных SSL сертификатов для домена и IP  ===" 
sudo mkdir /etc/ssl/nginx
mkdir ~/SSL

#=== Для домена  ===
openssl req -newkey rsa:2048 -sha256 -nodes -keyout $domain_name.self.key -x509 -days 365 -out $domain_name.self.crt -subj "/C=RU/ST=RT/L=KAZAN/O=Home/CN=$domain_name"
#=== Для IP  ===
openssl req -newkey rsa:2048 -sha256 -nodes -keyout $domain_ip.self.key -x509 -days 365 -out $domain_ip.self.crt -subj "/C=RU/ST=RT/L=KAZAN/O=Home/CN=$domain_ip"

#=== Копируем сертификаты в папку для Nginx (/etc/ssl/nginx) ===
sudo cp $domain_name.self.key /etc/ssl/nginx/$domain_name.key
sudo cp $domain_name.self.crt /etc/ssl/nginx/$domain_name.crt

sudo mv $domain_name.self.key /etc/ssl/nginx/
sudo mv $domain_name.self.crt /etc/ssl/nginx/

sudo mv $domain_ip.self.key /etc/ssl/nginx/
sudo mv $domain_ip.self.crt /etc/ssl/nginx/

#=== Делаем ссылки в домашнию папку SSL ===
sudo ln -s /etc/ssl/nginx/$domain_name.key ~/SSL/$domain_name.key
sudo ln -s /etc/ssl/nginx/$domain_name.crt ~/SSL/$domain_name.crt

sudo ln -s /etc/ssl/nginx/$domain_name.self.key ~/SSL/$domain_name.self.key
sudo ln -s /etc/ssl/nginx/$domain_name.self.crt ~/SSL/$domain_name.self.crt

sudo ln -s /etc/ssl/nginx/$domain_ip.self.key ~/SSL/$domain_ip.self.key
sudo ln -s /etc/ssl/nginx/$domain_ip.self.crt ~/SSL/$domain_ip.self.crt

sudo chown -R $USER:$USER ~/SSL

echo
echo "=== Запуск сервиса, службы (SYSTEMD) бота ===" 
echo
sudo cp /home/$USER/$proj_name/Service/Aiogram3_bot.service /lib/systemd/system/Aiogram3_bot.service
sudo systemctl daemon-reload
sudo systemctl enable Aiogram3_bot.service
sudo systemctl start Aiogram3_bot.service

#============================================

