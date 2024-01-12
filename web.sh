#!/bin/bash

#Lance les mises à jour
apt update -y && apt upgrade -y > /dev/nell 2>&1

#Lance l'installation des outils pour le service WEB
apt install -y apache2 libapache2-mod-php php-mysql sudo 
echo "Installation des outils pour un serveur web => okay" > /dev/nell 2>&1

#Ajout de thibaud dans le groupe sudo
gpasswd -a thibaud sudo

#Configuration du adresse IP fixe
echo "# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
iface eth0 inet static
address 192.168.0.101
netmask 255.255.255.0 
gateway 192.168.0.1
dns-nameservers 192.168.0.103 8.8.8.8
dns-domain beesafe.co " > /etc/network/interfaces
systemctl restart networking
echo "Redémarrage carte réseau"
echo "IP = $(hostname -I)"

#Utilisation de git clone pour récupérer le répertoire
cd /var/www
git clone https://github.com/OpenClassrooms-Student-Center/ASR-P4-BeeSafe

#Configuration d'un VirtualHost
echo "<VirtualHost *:80>
    ServerName beesafe.co
    ServerAlias www.beesafe.co
    DocumentRoot /var/www/ASR-P4-BeeSafe
    <Directory /var/www/ASR-P4-BeeSafe>
        Options -Indexes +FollowSymLinks +MultiViews
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog /var/log/apache2/beesafe.co-error.log
    CustomLog /var/log/apache2/beesafe.co-access.log combined
</VirtualHost>" > /etc/apache2/sites-available/beesafe.co.conf

#Création d'un lien symbolique du site beesafe.co et supperssion de 000-defaut.conf
ln -s /etc/apache2/sites-available/beesafe.co.conf /etc/apache2/sites-enabled/
rm /etc/apache2/sites-enabled/000-default.conf
systemctl restart apache2

#Modification du fichier vars.php pour intégrer la base de données mysql
echo "<?php
$servername = "192.168.0.102";
$username = 'service';
$password = 'Password';
$dbname = "beesafe";
?>" > /var/www/ASR-P4-BeeSafe/vars.php

#Modification de résolution de DNS
echo "domain numericable.fr
search numericable.fr
nameserver 192.168.0.103" > /etc/resolv.conf
