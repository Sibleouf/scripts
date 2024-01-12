#!/bin/bash

#Lance les mises à jour
apt update -y && apt upgrade -y > /dev/nell 2>&1

#Lance l'installation des outils pour le service SQL
apt install -y mariadb-server > /dev/nell 2>&1
echo "Installation de Maria DB => okay"

#Configuration du adresse IP fixe
echo "# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
iface eth0 inet static
address 192.168.0.102
netmask 255.255.255.0 
gateway 192.168.0.1
dns-nameservers 192.168.0.103 8.8.8.8
dns-domain beesafe.co " > /etc/network/interfaces
systemctl restart networking
echo "Redémarrage carte réseau"
echo "IP = $(hostname -I)"

#Utilisation de git clone pour récupérer le répertoire
cd /home/thibaud
git clone https://github.com/OpenClassrooms-Student-Center/ASR-P4-BeeSafe/
cd /home/thibaud/ASR-P4-BeeSafe/
git checkout sql 

#Création d'un compte et d'une base de données mysql
mysql -e "CREATE DATABASE beesafe;"
mysql -e "GRANT ALL ON beesafe.* TO 'service'@'192.168.0.101' identified by 'Buellxb984r';"


#Charger les fichiers de configurations dans la nouvealle base de données
mysql beesafe < /home/thibaud/ASR-P4-BeeSafe/sql/schema.sql
mysql beesafe < /home/thibaud/ASR-P4-BeeSafe/sql/data.sql



