#!/bin/bash
# Lance les mises à jour
apt update -y && apt upgrade -y  > /dev/null 2>&1
echo "Mises à jour => okay"

# Lance l'installation des outils utilisés pour le service web
apt install -y apache2 modapache2-php git php-mysql > /dev/null 2>&1
echo "Installation des outils pour un serveur web => okay"

# Configure la carte ethernet
# Contenu que vous souhaitez dans le fichier "interfaces"
# contenu="# The loopback network interface
# auto lo
# iface lo inet loopback

# # The primary network interface
# allow-hotplug eth0
# iface eth0 inet static
# address 192.168.0.26
# netmask 255.255.255.0 
# gateway 192.168.0.1
# dns-nameserveurs 192.168.0.29 8.8.8.8
# dns-domain beesafe.co
# "
# # Chemin complet du fichier
# chemin_fichier="/etc/network/interfaces"
# # Création du fichier avec son contenu"
# echo -e $contenu | tee $chemin_fichier > /dev/null 
echo "# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
iface eth0 inet static
address 192.168.0.26
netmask 255.255.255.0 
gateway 192.168.0.1
dns-nameserveurs 192.168.0.29 8.8.8.8
dns-domain beesafe.co
" > /etc/network/interfaces

echo "Redémarrage de la carte réseau => okay"
systemctl restart networking
echo "Configuration réseau modifié : " + $(hostname -I)

# Afficher l'adresse IP
# adresse_ip=$(echo -e "$contenu" | head -n 1)
# echo "Configuration réseau modifié : $adresse_ip"

# Redémarrage de la carte réseau
# systemctl restart networking
# echo "Redémarrage de la carte réseau => okay"

# Création d'un dossier pour mettre un clone git
# mkdir /home/thibaud/git 
# cd /home/thibaud/git 
# git clone https://github.com/OpenClassrooms-Student-Center/ASR-P4-BeeSafe

git clone https://github.com/OpenClassrooms-Student-Center/ASR-P4-BeeSafe /usr/share/git-web

ln -s /usr/share/git-web /var/www

# Modification des fichiers de configurations du site web
# mv /var/www/html/index.html /var/www/html/index-old.html
# cp /home/thibaud/git/git-web/* /var/www/html/
# mv /var/www/html/index.php /var/www/html/index.html

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

sudo a2dissite 000-default
sudo a2ensite beesafe.co

# Redémarrage du service apache2
systemctl restart apache2

# modification du fichier vars.php
