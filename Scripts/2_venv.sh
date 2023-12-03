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
read -p "=== Введите название проекта (папки): " proj_name
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
sudo cp -R /root/Aiogram3/Scripts ./
sudo cp -R /root/Aiogram3/Service ./
sudo cp -R /root/Aiogram3/Nginx ./
sudo cp -R /root/Aiogram3/main.py ./
sudo chown -R $USER:$USER ./

echo
echo "=== Установка Aiogram 3.2.0 ==="
pip3 install --upgrade pip
pip install aiogram==3.2.0
#pip install -r requirements.txt

echo
echo "=== Установка переменных окружения ===" 
echo
read -p "=== Введите токен телеграмм бота: " bot_token
echo "BOT_TOKEN='$bot_token'" | sudo tee -a /etc/environment
echo "RUN_USER='$USER'" | sudo tee -a /etc/environment

echo
echo "=== Подготовка SSL сертификата ===" 
echo
read -p "=== Введите имя домена или IP адрес: " domain_name
echo "DOMAIN_NAME='$domain_name'" | sudo tee -a /etc/environment
mkdir SSL
cd SSL
sudo mkcert -install $domain_name
mv $domain_name-key.pem $domain_name.key
mv $domain_name.pem $domain_name.crt

echo
echo "=== Запуск сервиса (SYSTEMD) бота ===" 
echo
sudo cp /home/$USER/$proj_name/Service/Aiogram3_bot.service /lib/systemd/system/Aiogram3_bot.service
#sudo ln -s /lib/systemd/system/Aiogram3_bot.service /etc/systemd/system/Aiogram3_bot.service
sudo systemctl daemon-reload
sudo systemctl enable Aiogram3_bot.service
sudo systemctl start Aiogram3_bot.service


#===============================
#wget https://raw.githubusercontent.com/Marat2010/Aiogram3/master/main.py
#wget https://raw.githubusercontent.com/Marat2010/Aiogram3/master/requirements.txt
#-----------------------------
#. /etc/environment
#source /etc/environment

