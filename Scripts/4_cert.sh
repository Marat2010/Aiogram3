#!/bin/bash

# --- Выполнять под пользователем root ---

echo "=== Выполнять под пользователем root ==="
echo "=== Подготовка SSL сертификата для Домена ===" 

# Установить попробовать  https://github.com/kshcherban/acme-nginx
cd ~
git clone https://github.com/kshcherban/acme-nginx
cd acme-nginx
python3 setup.py install
wait

acme-nginx -d $DOMAIN_NAME
wait

mv /etc/ssl/nginx/$DOMAIN_NAME.crt /etc/ssl/nginx/$DOMAIN_NAME.crt_self_old
mv /etc/ssl/nginx/$DOMAIN_NAME.key /etc/ssl/nginx/$DOMAIN_NAME.key_self_old

ln -s /etc/ssl/private/letsencrypt-domain.pem /etc/ssl/nginx/$DOMAIN_NAME.crt
ln -s /etc/ssl/private/letsencrypt-domain.key /etc/ssl/nginx/$DOMAIN_NAME.key

#==================================
echo
echo "=== Установка диспетчера задач для автоматического обноления SSL сертификата для Домена ===" 
echo "MAILTO=insider@prolinux.org
12 11 10 * * root timeout -k 600 -s 9 3600 /usr/local/bin/acme-nginx -d $DOMAIN_NAME >> /var/log/letsencrypt.log 2>&1 || echo Failed to renew certificate" > /etc/cron.d/renew-cert
crontab -l
#==================================
echo
echo "=== Перезапуск Nginx ==="
systemctl daemon-reload
systemctl restart nginx.service


#====================================

#~/.acme.sh/acme.sh  --issue  -d $DOMAIN_NAME  --nginx -m $EMAIL_ZEROSSL --server zerossl
#~/.acme.sh/acme.sh  --register-account  -m $EMAIL_ZEROSSL --server zerossl
#====================================
#sudo chown -R marat:marat /var/www/html/
#~/.acme.sh/acme.sh  --issue  -d $DOMAIN_NAME  --nginx /etc/nginx/sites-available/sv.conf --server zerossl

#~/.acme.sh/acme.sh --issue -d ub22.rupyt.site --nginx --server letsencrypt -w /var/www/html --debug 2
#~/.acme.sh/acme.sh  --issue  -d ub22.rupyt.site  --nginx /etc/nginx/sites-available/ub22.rupyt.site.conf --server zerossl -w /var/www/html --log

#~/.acme.sh/acme.sh  --issue  -d $DOMAIN_NAME  --nginx /etc/nginx/sites-available/nginx_bot.conf -m $EMAIL_ZEROSSL --server zerossl
# ~/.acme.sh/acme.sh  --issue  -d $DOMAIN_NAME  --nginx /etc/nginx/sites-available/sv.conf --server zerossl -w /var/www/html --log

#======================================
#cat certificate.crt ca_bundle.crt >> $DOMAIN_NAME.crt
#~/.acme.sh/acme.sh  --issue  -d $DOMAIN_NAME  --nginx /etc/nginx/sites-available/nginx_bot.conf -m $EMAIL_ZEROSSL --server zerossl

#======================================================

#cat certificate.crt ca_bundle.crt >> certificate.crt
#http://89.104.69.137/.well-known/pki-validation/C7B53CFFA9F38169AA5203AAE43A0677.txt
#------------------------------------

#wget -O -  https://get.acme.sh | sh -s email=$EMAIL_ZEROSSL
#~/.acme.sh/acme.sh  --issue  -d $DOMAIN_NAME  --nginx /etc/nginx/sites-available/nginx_bot.conf -m $EMAIL_ZEROSSL --server zerossl

# /etc/nginx/conf.d/example.com.conf
# /etc/nginx/nginx.conf
# /etc/nginx/sites-available/nginx_bot.conf
# /etc/nginx/sites-available/sv.conf
#-----------------------
#echo
#echo "=== Подготовка SSL сертификата для Домена ===" 
#sudo mkcert -install $domain_name
#sudo mkdir /etc/ssl/nginx
#sudo mv $domain_name-key.pem /etc/ssl/nginx/$domain_name.key
#sudo mv $domain_name.pem /etc/ssl/nginx/$domain_name.crt
#mkdir ~/$PROJECT_NAME/SSL
#sudo ln -s /etc/ssl/nginx/$domain_name.key ~/$PROJECT_NAME/SSL/$domain_name.key

#sudo mkdir /etc/ssl/nginx
#sudo cp ~/$PROJECT_NAME/SSL/fullchain.pem /etc/ssl/nginx/$DOMAIN_NAME.crt
#sudo cp ~/$PROJECT_NAME/SSL/privkey.pem /etc/ssl/nginx/$DOMAIN_NAME.key
