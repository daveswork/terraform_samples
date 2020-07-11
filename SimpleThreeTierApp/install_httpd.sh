#!/bin/bash

yum update -y
yum install httpd -y
yum install postgresql -y
sed -i s/'Listen 80'/'Listen 8080'/ /etc/httpd/conf/httpd.conf
echo "Hello world!" > /var/www/html/index.html
systemctl start httpd
systemctl enable httpd
