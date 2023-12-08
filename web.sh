#!/bin/bash
# Lance les mises à jour
apt update -y && apt upgrade -y
echo "Mises à jour => okay"

# Lance l'installation des outils utilisés pour le service web
apt install apache2 -y && apt install php -y && apt install git -y
echo "Installation des outils pour un serveur web => okay"

# Configure la carte ethernet
# Contenu que vous souhaitez dans le fichier "interfaces"
contenu="address 192.168.0.26
netmask 255.255.255.0 
gateway 192.168.0.1
dns-nameserveurs 192.168.0.29 8.8.8.8
dns-domain beesafe.co
"
# Chemin complet du fichier
chemin_fichier=" /etc/network/interfaces"
# Création du fichier avec son contenu"
echo -e "$contenu" | tee "$chemin_fichier" > /dev/null 
# Afficher l'adresse IP
adresse_ip=$(echo -e "$contenu" | head -n 1)
echo "Configuration réseau modifié : $adresse_ip"

# Redémarrage de la carte réseau
systemctl restart networking
echo "Redémarrage de la carte réseau => okay"

# Création d'un dossier pour mettre un clone git
mkdir /home/thibaud/git 
cd /home/thibaud/git 
git clone https://github.com/OpenClassrooms-Student-Center/ASR-P4-BeeSafe

# Modification des fichiers de configurations du site web
 mv */ git-web
cd ~
mv /var/www/html/index.html /var/www/html/index-old.html
cp /home/thibaud/git/git-web/* /var/www/html/
mv /var/www/html/index.php /var/www/html/index.html
