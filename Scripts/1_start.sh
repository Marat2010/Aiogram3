#!/bin/bash

echo "=== !!! Выполнять под пользователем root !!! ==="

if [ $USER != 'root' ]; then
    echo "=== Вы пользователь '$USER', необходимо запустить под пользователем: 'root'!"
    exit
fi

# ---- Установка пакетов --------

apt update
echo
echo "=== Установка FTP сервера ==="
echo "=== Инструкция: https://help.reg.ru/support/servery-vps/oblachnyye-servery/ustanovka-programmnogo-obespecheniya/kak-ustanovit-ftp-server-na-ubuntu ==="
apt -y install vsftpd
systemctl enable vsftpd
echo
echo "=== Установка Midnight Commander ==="
apt -y install mc
echo
echo "=== Установка модуля VENV (python3-venv) ==="
apt -y install python3-venv

echo
echo "=== FTP: Настройка сервера ==="
cp /etc/vsftpd.conf /etc/vsftpd.conf.original

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
echo "=== FTP: Формирование SSL-сертификата  ==="
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.pem -out /etc/ssl/private/vsftpd.pem -subj "/C=RU/ST=RT/L=KAZAN/O=Home/CN=1/emailAddress=em"

echo "rsa_cert_file=/etc/ssl/private/vsftpd.pem" >> /etc/vsftpd.conf
echo "rsa_private_key_file=/etc/ssl/private/vsftpd.pem" >> /etc/vsftpd.conf
echo "ssl_enable=YES" >> /etc/vsftpd.conf
echo "" >> /etc/vsftpd.conf

systemctl restart vsftpd

echo
echo "=== Отключение dhclient6 ==="
systemctl stop dhclient6.service
systemctl disable dhclient6.service

# ---- Добавление и настройка пользователя --------

echo
read -p "=== Введите имя пользователя для проекта: " proj_user

if [ ! -z $proj_user ]
then
    adduser --gecos "" $proj_user
    usermod -aG sudo $proj_user
    echo "=== Пользователь '$proj_user' в группе 'sudo' ==="

    echo $proj_user | tee -a /etc/vsftpd.userlist
    echo "=== Пользователю '$proj_user' открыт доступ по FTP ==="

    echo "=== Установка переменных окружения ===" 
    echo "PROJECT_USER='$proj_user'" | tee -a /etc/environment
fi

echo
echo "=== Копирование скриптов в каталог пользователя '$proj_user' ==="

git clone https://github.com/Marat2010/Aiogram3
wait

cp -R Aiogram3/Scripts/.config ~/
cp -R Aiogram3/Scripts /root/

cp -R Aiogram3/Scripts /home/$proj_user/
cp -R /home/$proj_user/Scripts/.config /home/$proj_user/

chown -R $proj_user:$proj_user "/home/$proj_user/Scripts"
chown -R $proj_user:$proj_user "/home/$proj_user/.config"

chmod +x -R "/home/$proj_user/Scripts"

# ---- Смена пароля root-а --------

echo 
read -p "=== Сменить у пользователя 'root' пароль? [y/N]: " change_passwd_root

if [ "$change_passwd_root" == "y" ]
then
    passwd root
fi

#========================================================

