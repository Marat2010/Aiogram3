#!/bin/bash

# ---- Инструкция по запуску FTP сервера здесь: --------
# https://help.reg.ru/support/servery-vps/oblachnyye-servery/ustanovka-programmnogo-obespecheniya/kak-ustanovit-ftp-server-na-ubuntu

sudo chmod +x start.sh

# ---- Установка FTP сервера --------

sudo apt update
echo "=== Установка FTP сервера ==="
sudo apt -y install vsftpd
sudo systemctl enable vsftpd

# ---- Установка Midnight Commander --------

echo "=== Установка Midnight Commander ==="
sudo apt -y install mc

# ---- Настройка FTP сервера --------

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

echo "=== Формирование SSL-сертификата для FTP ==="
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.pem -out /etc/ssl/private/vsftpd.pem

echo "rsa_cert_file=/etc/ssl/private/vsftpd.pem" >> /etc/vsftpd.conf
echo "rsa_private_key_file=/etc/ssl/private/vsftpd.pem" >> /etc/vsftpd.conf
echo "ssl_enable=YES" >> /etc/vsftpd.conf
echo "" >> /etc/vsftpd.conf

sudo systemctl restart vsftpd

# ---- Добавление и настройка пользователя --------

echo "=== Введите имя пользователя для доступа по FTP: ==="
read user_ftp

if [ ! -z $user_ftp ]
then
    sudo adduser $user_ftp
    sudo usermod -aG sudo $user_ftp
    echo "=== Пользователь '$user_ftp' в группе 'sudo' ==="
    echo $user_ftp | sudo tee -a /etc/vsftpd.userlist
    echo "=== Пользователю '$user_ftp' открыт доступ по FTP ==="
fi

# ---- Смена пароля root-а --------

echo "=== Сменить пароль пользователя root? [y/N] ==="
read change_passwd_root

if [ "$change_passwd_root" == "y" ]
then
    sudo passwd root
fi



