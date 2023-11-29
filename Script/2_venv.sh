#!/bin/bash

# --- Выполнять под пользователем (не root) ---

chmod +x 2_venv.sh

sudo apt update
echo "=== Установка модуля venv ==="
sudo apt -y install python3-venv

echo "=== Установка mkcert ==="
sudo apt -y install mkcert

echo "=== Введите название проекта (папки): ==="
read proj_name
mkdir ~/$proj_name
cd ~/$proj_name

echo "=== Установка вирт. окружения в папке $proj_name ==="
python3 -m venv venv

echo "=== Активация вирт.окружения ==="
source venv/bin/activate

echo "=== Установка Aiogram 3.2.0 ==="
pip3 install --upgrade pip
pip install aiogram==3.2.0

echo
echo "=== Установка переменных окружения (BOT_TOKEN)==="
echo "=== Введите токен телеграмм бота: ==="
read bot_token
echo "BOT_TOKEN='$bot_token'" | sudo tee -a /etc/environment
#. /etc/environment
#source /etc/environment

echo "=== Подготовка SSL сертификата ==="
echo "=== Введите  имя домена или IP адрес: ==="
read domain_name
mkdir SSL
cd SSL
sudo mkcert $domain_name
mv $domain_name-key.pem $domain_name.key
mv $domain_name.pem $domain_name.crt

