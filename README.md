sites_sym_link
==============

Add sym link from another directory to /var/www then sets up the hosts and new vhosts.
Accepts multiple vhosts.

---
Usage:
./sites_sym_link.sh folder1 folder2 ...

The folders should already exist in the site install directory.
THe folder names will alse be used in the virtual host domain.

---
Defaults:

DIRECTORY=/home/$USER/Sites

  -> place where your files exist

ROOT=/var/www

  -> htdocs root where your server reads the files. symlinks will be put here.

APACHE_SITES=/etc/apache2/sites-available

  -> place where vhost files will be put

HOSTS=/etc

  -> location of hosts file

HOST_IP=127.0.0.1

  - the ip that will be associated with the folder
