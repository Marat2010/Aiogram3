#!/bin/bash

echo "=== !!! Выполнять под пользователем root !!! ==="

if [ $USER != 'root' ]; then
    echo "=== Вы пользователь '$USER', необходимо запустить под пользователем: 'root'!"
    exit
fi

if [[ -z $PROJECT_NAME || -z $DOMAIN_NAME || -z $BOT_TOKEN || -z $EMAIL_SSL ]]; then
    echo "=== Нет необходимых переменных окружения (PROJECT_NAME, DOMAIN_NAME, BOT_TOKEN, EMAIL_SSL) ! ==="
    echo "=== Необходимо перезайти под root-ом (exit, exit, ssh root@xxx.xxx.xxx.xxx)! ==="
    exit
fi

#======= Временно удаляем наши конфигурации Nginx ===========
rm -f /etc/nginx/sites-enabled/nginx_bot
rm -f /etc/nginx/sites-enabled/$DOMAIN_NAME.conf
echo
echo "=== Перезапуск Nginx ==="
systemctl daemon-reload
systemctl restart nginx.service
#=============================================================

echo
echo "=== Установка пакета acme-nginx ===" 
cd ~
git clone https://github.com/kshcherban/acme-nginx
cd acme-nginx
python3 setup.py install
wait
#sleep 2

echo
echo "=== Установка бесплатных сертификатов SSL (Let's Encrypt) для домена (Nginx)==="
echo "=== Инструкция: https://github.com/kshcherban/acme-nginx"
acme-nginx -d $DOMAIN_NAME --debug
wait
#sleep 2

#======= Восстановим наши конфигурации Nginx ===============
ln -s /etc/nginx/sites-available/nginx_bot.conf /etc/nginx/sites-enabled/nginx_bot
ln -s /etc/nginx/sites-available/$DOMAIN_NAME.conf /etc/nginx/sites-enabled/$DOMAIN_NAME.conf
#===========================================================

#======= Делаем ссылки на новые сертификаты для Nginx ======
rm -f /etc/ssl/nginx/$DOMAIN_NAME.crt
rm -f /etc/ssl/nginx/$DOMAIN_NAME.key
ln -s /etc/ssl/private/letsencrypt-domain.pem /etc/ssl/nginx/$DOMAIN_NAME.crt
ln -s /etc/ssl/private/letsencrypt-domain.key /etc/ssl/nginx/$DOMAIN_NAME.key
#==========================================================

echo
echo "=== Установка диспетчера задач для автоматического обноления SSL сертификата для Домена ===" 

echo "MAILTO=$EMAIL_SSL
`date +'%M'` `date +'%H'` `date +'%d'` * * root timeout -k 600 -s 9 3600 /usr/local/bin/acme-nginx -d $DOMAIN_NAME >> /var/log/letsencrypt.log 2>&1 || echo Failed to renew certificate" > /etc/cron.d/renew-cert

cat /etc/cron.d/renew-cert
#==================================
echo
echo "=== Перезапуск Nginx ==="
systemctl daemon-reload
systemctl restart nginx.service
echo
echo "=== НАСТРОЙКА ЗАВЕРШЕНА! ==="
echo "=== Проверка по адресу: https://$DOMAIN_NAME:8443/ ==="
echo "=== Адрес WEBHOOK_URL: https://$DOMAIN_NAME:8443/$PROJECT_NAME ==="
echo "=== Проверка состояния ТГ вебхука: https://api.telegram.org/bot$BOT_TOKEN/getWebhookInfo ==="


#==============================================================================
#cat certificate.crt ca_bundle.crt >> $DOMAIN_NAME.crt
#wget -O -  https://get.acme.sh | sh -s email=$EMAIL_ZEROSSL
#~/.acme.sh/acme.sh  --issue  -d $DOMAIN_NAME  --nginx /etc/nginx/sites-available/nginx_bot.conf -m $EMAIL_ZEROSSL --server zerossl
#http://89.104.69.137/.well-known/pki-validation/C7B53CFFA9F38169AA5203AAE43A0677.txt

#======================================


