#!/bin/bash

#Lance les mises à jour
apt update -y && apt upgrade -y > /dev/nell 2>&1

#Lance l'installation des outils pour le service DNS
apt install -y bind9 sudo > /dev/nell 2>&1

#Ajout de thibaud dans le groupe sudo
gpasswd -a thibaud sudo

#Configuration du adresse IP fixe
echo "# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
iface eth0 inet static
address 192.168.0.103
netmask 255.255.255.0 
gateway 192.168.0.1
dns-nameservers 192.168.0.103 8.8.8.8
dns-domain beesafe.co " > /etc/network/interfaces
systemctl restart networking
echo "Redémarrage carte réseau"
echo "IP = $(hostname -I)"

#Configuration des options global de Bind
echo 'options {
        directory "/var/cache/bind";

        forwarders {
            8.8.8.8;
            8.8.4.4;
        };

        dnssec-validation auto;

        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
};
' > /etc/bind/named.conf.options

#Création du dossier zones
mkdir /etc/bind/zones

#Création d'un fichier de zone pour le domaine beesafe.co
echo "$TTL    604800
@       IN      SOA     beesafe.co. admin.beesafe.co. (
                     2021122801         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      beesafe.co.
@       IN      A       192.168.0.103
www     IN      A       192.168.0.101
" > /etc/bind/zones/db.beesafe.co

#Ajouter une référence à votre fichier de zone
echo 'zone "beesafe.co" {
    type master;
    file "/etc/bind/zones/db.beesafe.co";
};

zone "0.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.192.168.0";
};
' > /etc/bind/named.conf.local

#Création d'une zone inversée

echo "$TTL    604800
@       IN      SOA     beesafe.co. admin.beesafe.co. (
                 2021122801         ; Serial
                     604800         ; Refresh
                      86400         ; Retry
                    2419200         ; Expire
                     604800 )       ; Negative Cache TTL
;
@       IN      NS      beesafe.co.
103     IN      PTR     beesafe.co.
101     IN      PTR     www.beesafe.co.
" > /etc/bind/zones/db.192.168.0


#Redémarrage du service bind
systemctl restart named.service

#Modification de résolution de DNS
echo "nameserver 192.168.0.103
nameserver 8.8.8.8" > /etc/resolv.conf
