#!/bin/bash
# Sites Sym Link. Written by Japo Domingo
# Adds Sym Links when your sites directory resides somewhere other than the /var/www default.
# It also adds the respective Virtual Host entries and edits the hosts file
#
# I've written this up because I prefer to keep my files in a Sites folder in my home/user/ directory
#

echo "Setting up Sym Links"

DEF_DIRECTORY=/home/$USER/Sites
DEF_ROOT=/var/www
DEF_APACHE_SITES=/etc/apache2/sites-available
DEF_HOSTS=/etc
DEF_HOST_IP=127.0.0.1
# optional
DEF_DEV_DOMAIN="myrtdev.com"

echo "  ---CONFIG---  "

LOOP=true
while $LOOP; do
  read -p "Site install directory.(default=$DEF_DIRECTORY):" DIRECTORY
  if [[ $DIRECTORY == "" ]]; then
    DIRECTORY=$DEF_DIRECTORY
  fi
  if [[ -d $DIRECTORY ]]; then
    LOOP=false
  else
    echo -e "\033[33m$DIRECTORY is not a valid directory\033[33m"
    echo -e "\033[0m"
  fi
done

LOOP=true
while $LOOP; do
  read -p "Web root.(default=$DEF_ROOT):" ROOT
  if [[ $ROOT == "" ]]; then
    ROOT=$DEF_ROOT
  fi
  if [[ -d $ROOT ]]; then
    LOOP=false
  else
    echo -e "\033[33m$ROOT is not a valid directory\033[33m"
    echo -e "\033[0m"
  fi
done

LOOP=true
while $LOOP; do
  read -p "Apache folder.(default=$DEF_APACHE_SITES):" APACHE_SITES
  if [[ $APACHE_SITES == "" ]]; then
    APACHE_SITES=$DEF_APACHE_SITES
  fi
  if [[ -d $APACHE_SITES ]]; then
    LOOP=false
  else
    echo -e "\033[33m$APACHE_SITES is not a valid directory\033[33m"
    echo -e "\033[0m"
  fi
done

LOOP=true
while $LOOP; do
  read -p "HOSTS file directory.(default=$DEF_HOSTS):" HOSTS
  if [[ $HOSTS == "" ]]; then
    HOSTS=$DEF_HOSTS
  fi
  if [[ -d $HOSTS ]]; then
    LOOP=false
  else
    echo -e "\033[33m$HOSTS is not a valid directory\033[33m"
    echo -e "\033[0m"
  fi
done

read -p "Development Domain. Appended to hostnames.(default=$DEF_DEV_DOMAIN):" DEV_DOMAIN
if [[ $DEV_DOMAIN == "" ]]; then
  DEV_DOMAIN=$DEF_DEV_DOMAIN
fi

read -p "Host IP for hosts file(default=$DEF_HOST_IP):" HOST_IP
if [[ $HOST_IP == "" ]]; then
  HOST_IP=$DEF_HOST_IP
fi

echo "  ---STARTING PROCESS---  "

# ITERATE OVER EACH PARAMETER

for i
do
  if [[ -d $DIRECTORY/$i ]]; then
    echo "--> $i"
    if [[ ! -d $ROOT/$i ]]; then
      sudo ln -s $DIRECTORY/$i $ROOT/$i
      echo " $ROOT/$i linked to:$DIRECTORY/$i"
    else
      echo -e "\033[33m$ROOT/$i already exists. Please check.\033[33m"
      echo -e "\033[0m"
    fi

    grep $i.$DEV_DOMAIN $HOSTS/hosts
    if [ ! $? -eq 0 ]; then
      echo "$HOST_IP $i.$DEV_DOMAIN" | sudo tee -a $HOSTS/hosts
      echo "Added $i.$DEV_DOMAIN at $HOST_IP to $HOSTS/hosts"
    else
      echo -e "\033[33m$i.$DEV_DOMAIN already exists in your hosts file. Please check.\033[33m"
      echo -e "\033[0m"
    fi

    sudo touch $APACHE_SITES/$i
    echo "<VirtualHost *:80>
  ServerName $i.$DEV_DOMAIN
  ServerAlias $i.$DEV_DOMAIN
  DocumentRoot $ROOT/$i
  <Directory />
    Options FollowSymLinks
    AllowOverride All
  </Directory>
</VirtualHost>" | sudo tee $APACHE_SITES/$i
    echo "Added $APACHE_SITES/$i"

    sudo a2ensite $i
    sudo service apache2 reload
    echo "--"

  else
    echo -e "\033[33m$DIRECTORY/$i is not a valid directory\033[33m"
    echo -e "\033[0m"
  fi
done

