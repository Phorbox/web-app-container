#!/bin/bash
# bash makit.sh "mysql pw" "dns"

apt-get update
apt-get upgrade -y
apt-get install -y nginx mysql-server php-fpm gh

mv configs/self-signed.conf /etc/nginx/snippets/self-signed.conf
mv configs/ssl-params.conf /etc/nginx/snippets/ssl-params.conf
mv configs/default /etc/nginx/sites-available/default
chown -R root:root /etc/nginx/snippets/
chown -R root:root /etc/nginx/sites-available/

mysql -u root -e " USE mysql; ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${1}'; FLUSH PRIVILEGES;"

echo "In sed"
sed -i "s/%%%%/${2}/g" /etc/nginx/sites-available/default
sed -i "s/%%%%/${2}/g" configs/cert_ext.cnf

echo "In ssl Generation"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -config configs/cert_ext.cnf
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

echo "nginx fixin"
service nginx reload
chown -R ubuntu:www-data /var/www/html/

echo "PHP my admin!"
mv /var/www/html/index.nginx-debian.html /var/www/html/index.php
apt-get install -y phpmyadmin
ln -s /usr/share/phpmyadmin /var/www/html/dbadmin

echo ""
echo "mysql password: ${1}"
echo "index: https://${2}/"
echo "dbadmin: https://${2}/dbadmin"
echo ""