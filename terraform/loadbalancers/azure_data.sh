#! /bin/bash
sudo su
apt-get update -y
apt-get install apache2 -y
systemctl enable apache2
systemctl start apache2
echo "<h1> Azure linux VM with web server - : $(hostname) </h1>" | tee /var/www/html/index.html
