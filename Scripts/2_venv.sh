#!/bin/bash

# --- Выполнять под пользователем проекта (не root) ---

sudo apt update
echo
echo "=== Установка модуля VENV ==="
sudo apt -y install python3-venv

echo
echo "=== Установка пакета mkcert (SSL) ==="
sudo apt -y install mkcert

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
sudo cp /root/Aiogram3/main.py ./
sudo cp /root/Aiogram3/bot.html ./
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
echo "=== Установка переменных окружения ===" 
echo "BOT_TOKEN='$bot_token'" | sudo tee -a /etc/environment
echo "PROJECT_NAME='$proj_name'" | sudo tee -a /etc/environment

echo
echo "=== Запуск сервиса (SYSTEMD) бота ===" 
echo
sudo cp /home/$USER/$proj_name/Service/Aiogram3_bot.service /lib/systemd/system/Aiogram3_bot.service
sudo systemctl daemon-reload
sudo systemctl enable Aiogram3_bot.service
sudo systemctl start Aiogram3_bot.service


#============================================
#wget https://raw.githubusercontent.com/Marat2010/Aiogram3/master/main.py
#wget https://raw.githubusercontent.com/Marat2010/Aiogram3/master/requirements.txt
#-----------------------------
#pip install -r requirements.txt
#sudo ln -s /lib/systemd/system/Aiogram3_bot.service /etc/systemd/system/Aiogram3_bot.service
#. /etc/environment
#source /etc/environment

