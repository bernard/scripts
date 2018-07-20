#!/bin/bash

# Script pour le backup automatise d'un installation Wordpress
# Utilise WP-CLI voir
# https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

if [ "$#" -lt 1 ]; then
   echo "Pas assez d'arguments"
   echo "Usage: $0 [path_to_wordpress]"
   echo "Ex: $0 /var/www/wordpress"

   exit

fi

if [ ! -e "/usr/local/bin/wp" ]; then
   echo "[-] telechargement de wp-cli"
   curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /tmp/wp-cli.phar

   echo "[-] installation de wp-cli dans /usr/local/bin"
   mv /tmp/wp-cli.phar /usr/local/bin/wp
   sudo chmod +x /usr/local/bin/wp

fi

wp_path=$1
today_date=`date +"%d%m%Y"`
bck_path=/tmp/backup-${today_date}

echo "[-] creation du repertoire de backup"
mkdir ${bck_path}
cd ${bck_path}

echo "[-] export de la BD"
wp db export --allow-root --path=${wp_path}

echo "[-] backup de l'installation"
tar zcf ./wp-backup-${today_date}.tar.gz ${wp_path}

echo "Le backup se trouve a l'endroit suivant: ${bck_path}"
