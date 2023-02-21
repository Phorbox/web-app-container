FROM ubuntu:latest

EXPOSE 443
EXPOSE 80

# 
RUN apt-get update --yes\
    apt-get upgrade --yes\
    apt-get install nginx --yes\
    apt-get install mysql-server --yes

ARG PW
RUN mysql\
    use mysql;\
    SELECT user, authentication_string, plugin, host FROM user;\
    ALTER USER "root"@"localhost" IDENTIFIED WITH mysql_native_password BY "$PW";\
    FLUSH PRIVILEGES;\
    exit;

RUN apt-get install php-fpm --yes

COPY configs/cert_ext.cnf cert_ext.cnf

ARG DNS
RUN echo "commonName              = ${DNS}" >> cert_ext.cnf

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -config cert_ext.cnf\
    openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048    

COPY configs/self-signed.conf /etc/nginx/snippets/self-signed.conf
COPY configs/ssl-params.conf /etc/nginx/snippets/ssl-params.conf
COPY configs/default /etc/nginx/sites-available/default

RUN apt-get install phpMyAdmin --yes\
    ln -s /usr/share/phpmyadmin /var/www/html/dbadmin

RUN sed -i "s/%%%%/${DNS}/g" /etc/nginx/sites-available/default

