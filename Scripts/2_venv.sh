#!/bin/bash

# --- Выполнять под пользователем (не root) ---

chmod +x 2_venv.sh

sudo apt update
echo
echo "=== Установка модуля VENV ==="
sudo apt -y install python3-venv

echo
echo "=== Установка пакета mkcert (SSL) ==="
sudo apt -y install mkcert

echo 
read "=== Введите название проекта (папки): " proj_name
echo "PROJECT_NAME='$proj_name'" | sudo tee -a /etc/environment
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
wget https://raw.githubusercontent.com/Marat2010/Aiogram3/master/main.py
wget https://raw.githubusercontent.com/Marat2010/Aiogram3/master/requirements.txt
wget https://github.com/Marat2010/Aiogram3/tree/95aa47ff90f2ad1600672d2c76457c0c511ed03a/Scripts

echo
echo "=== Установка Aiogram 3.2.0 ==="
pip3 install --upgrade pip
pip install aiogram==3.2.0
#pip install -r requirements.txt

echo
echo "=== Установка переменных окружения (BOT_TOKEN)===" 
echo
read "=== Введите токен телеграмм бота: " bot_token
echo "BOT_TOKEN='$bot_token'" | sudo tee -a /etc/environment

echo
echo "=== Подготовка SSL сертификата ===" 
echo
read "=== Введите имя домена или IP адрес: " domain_name
echo "DOMAIN_NAME='$domain_name'" | sudo tee -a /etc/environment
mkdir SSL
cd SSL
sudo mkcert $domain_name
mv $domain_name-key.pem $domain_name.key
mv $domain_name.pem $domain_name.crt

#. /etc/environment
#source /etc/environment

