#!/bin/bash

# Script pour la creation d'un environnement wordpress
# Telecharge et install la derniere version de wordpress

# ***Changer le mot de passe de la BD (BD_PASSWORD)***

if [ `id|cut -c5` -ne 0 ]; then
        echo "Vous devez etre 'root' pour executer ce script"
        exit

fi


if [ "$#" -lt 1 ]; then
        echo "Pas assez d'arguments"
        echo "Usage: $0 [nom_env]"

        exit

fi

nom_env=$1
env_path=/var/www/$nom_env

wget -O /tmp/latest.tar.gz http://wordpress.org/latest.tar.gz

mkdir $env_path

cd $env_path

tar zvxf /tmp/latest.tar.gz

mv ./wordpress/* . && rmdir wordpress

cd /var/www && chmod -R g+w ./$nom_env

echo "create database $nom_env;grant all privileges on $nom_env.* to \"root\"@\"localhost\" identified by \"BD_PASSWORD\";flush privileges" > /tmp/db_script.sql

mysql -u root -p < /tmp/db_script.sql

rm /tmp/db_script.sql
