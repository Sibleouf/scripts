#!/bin/bash
# Lance les mises à jour
apt update -y && apt upgrade -y  > /dev/null 2>&1
echo "Mises à jour => okay"

# Lance l'installation des outils utilisés pour le service web
apt install -y apache2 php-mysql > /dev/null 2>&1
echo "Installation des outils pour un serveur web => okay"

# Configure la carte ethernet
echo "# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
iface eth0 inet static
address 192.168.0.26
netmask 255.255.255.0 
gateway 192.168.0.1
dns-nameservers 192.168.0.29 8.8.8.8
dns-domain beesafe.co
" > /etc/network/interfaces

systemctl restart networking
echo "Redémarrage de la carte réseau"
echo "IP = $(hostname -I)"

# Création d'un dossier pour mettre un clone git dans /usr/share/git-web
git clone https://github.com/OpenClassrooms-Student-Center/ASR-P4-BeeSafe /usr/share/git-web

#Création d'un lien symbolique entre /usr/share/git-web et /var/www
ln -s /usr/share/git-web /var/www

# creation virtual host beesafe.co
echo "<VirtualHost *:80>
    ServerName beesafe.co
    ServerAlias www.beesafe.co
    DocumentRoot /var/www/git-web
    <Directory /var/www/git-web>
        Options -Indexes +FollowSymLinks +MultiViews
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog /var/log/apache2/beesafe.co-error.log
    CustomLog /var/log/apache2/beesafe.co-access.log combined
</VirtualHost>" > /etc/apache2/sites-available/beesafe.co.conf

a2dissite 000-default
a2ensite beesafe.co

# Redémarrage du service apache2
systemctl restart apache2

