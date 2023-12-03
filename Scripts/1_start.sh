#!/bin/bash

# ---- Взято с инструкции по запуску FTP сервера здесь: --------
# https://help.reg.ru/support/servery-vps/oblachnyye-servery/ustanovka-programmnogo-obespecheniya/kak-ustanovit-ftp-server-na-ubuntu

sudo chmod +x 1_start.sh

# ---- Установка FTP сервера --------

sudo apt update
echo
echo "=== Установка FTP сервера ==="
sudo apt -y install vsftpd
sudo systemctl enable vsftpd

# ---- Установка Midnight Commander --------

echo
echo "=== Установка Midnight Commander ==="
sudo apt -y install mc

# ---- Настройка FTP сервера --------

echo
echo "=== Настройка FTP сервера ==="
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.original

echo "listen=YES" > /etc/vsftpd.conf
echo "listen_ipv6=NO" >> /etc/vsftpd.conf
echo "anonymous_enable=NO" >> /etc/vsftpd.conf
echo "local_enable=YES" >> /etc/vsftpd.conf
echo "write_enable=YES" >> /etc/vsftpd.conf
echo "local_umask=022" >> /etc/vsftpd.conf
echo "dirmessage_enable=YES" >> /etc/vsftpd.conf
echo "use_localtime=YES" >> /etc/vsftpd.conf
echo "xferlog_enable=YES" >> /etc/vsftpd.conf
echo "connect_from_port_20=YES" >> /etc/vsftpd.conf
echo "xferlog_file=/var/log/vsftpd.log" >> /etc/vsftpd.conf
echo "xferlog_std_format=YES" >> /etc/vsftpd.conf
echo "chroot_local_user=YES" >> /etc/vsftpd.conf
echo "allow_writeable_chroot=YES" >> /etc/vsftpd.conf
echo "pam_service_name=vsftpd" >> /etc/vsftpd.conf
echo "userlist_enable=YES" >> /etc/vsftpd.conf
echo "userlist_file=/etc/vsftpd.userlist" >> /etc/vsftpd.conf
echo "userlist_deny=NO" >> /etc/vsftpd.conf
echo "" >> /etc/vsftpd.conf

echo
echo "=== Формирование SSL-сертификата для FTP ==="
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.pem -out /etc/ssl/private/vsftpd.pem

echo "rsa_cert_file=/etc/ssl/private/vsftpd.pem" >> /etc/vsftpd.conf
echo "rsa_private_key_file=/etc/ssl/private/vsftpd.pem" >> /etc/vsftpd.conf
echo "ssl_enable=YES" >> /etc/vsftpd.conf
echo "" >> /etc/vsftpd.conf

sudo systemctl restart vsftpd

# ---- Добавление и настройка пользователя --------

echo
read -p "=== Введите имя пользователя для проекта: " proj_user

if [ ! -z $proj_user ]
then
    sudo adduser $proj_user
    sudo usermod -aG sudo $proj_user
    echo "=== Пользователь '$proj_user' в группе 'sudo' ==="

    echo $proj_user | sudo tee -a /etc/vsftpd.userlist
    echo "=== Пользователю '$proj_user' открыт доступ по FTP ==="
fi

mkdir "/home/$proj_user/Scripts"

echo
echo "=== Копирование скриптов в каталог пользователя $proj_user ==="

git clone https://github.com/Marat2010/Aiogram3

cp -R Aiogram3/Scripts /home/$proj_user/
sudo chown -R $proj_user:$proj_user "/home/$proj_user/Scripts"
chmod +x -R "/home/$proj_user/Scripts"

# ---- Смена пароля root-а --------

echo 
read -p "=== Сменить у пользователя 'root' пароль? [y/N]: " change_passwd_root

if [ "$change_passwd_root" == "y" ]
then
    sudo passwd root
fi

#========================================================
#gh repo clone Marat2010/Aiogram3
#wget -O "/home/$proj_user/Scripts/1_start.sh" https://raw.githubusercontent.com/Marat2010/Aiogram3/master/Scripts/1_start.sh
#    echo "PROJECT_USER='$proj_user'" | sudo tee -a /etc/environment
#    echo "=== Пользователь '$proj_user' ==="


