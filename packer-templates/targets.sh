#! /bin/bash

echo 'Post Install: SamuraiWTF tools and targets...'

a2enmod ssl
a2enmod headers
a2dissite 000-default
cp /opt/samurai/install/000-default.conf /etc/apache2/sites-available/
a2ensite 000-default
a2ensite vulnscripts


echo '>>> Installing Samurai Dojo target applications...'
cd /usr/share
git clone https://github.com/SamuraiWTF/Samurai-Dojo.git samurai-dojo
#|cp samurai-dojo/dojo-basic.conf /etc/apache2/sites-available/
#|cp samurai-dojo/dojo-scavenger.conf /etc/apache2/sites-available/
cd /usr/share/samurai-dojo/basic
phpenmod mysqli
php reset-db.php
mysqladmin -u root -psamurai create samurai_dojo_scavenger
mysql -u root -psamurai samurai_dojo_scavenger < /usr/share/samurai-dojo/scavenger/scavenger.sql

a2ensite dojo-basic
a2ensite dojo-scavenger


echo '>>> Installing Mutillidae...'
cd /usr/share
git clone git://git.code.sf.net/p/mutillidae/git mutillidae
# TODO - Fix this cert
cp samurai-dojo/ssl.crt mutillidae/
a2ensite mutillidae


echo '>>> Installing DVWA...'
cd /usr/share
git clone https://github.com/RandomStorm/DVWA.git dvwa
# TODO - Fix this cert
cp samurai-dojo/ssl.crt dvwa/
cd /usr/share/dvwa
sed -i 's/p@ssw0rd/samurai/g' config/config.inc.php
chmod 777 hackable/uploads/
chmod 666 external/phpids/0.6/lib/IDS/tmp/phpids_log.txt
a2ensite dvwa


echo '>>> Installing bWAPP...'
cd /usr/share
git clone git://git.code.sf.net/p/bwapp/code bwapp
cd /usr/share/bwapp/bWAPP
chmod 777 passwords/
chmod 777 images/
chmod 777 documents/
mkdir logs
chmod 777 logs/
sed -i 's/\$db_password = "bug";/\$db_ssword = "samurai";/g' admin/settings.php

# TODO - Initialize DB, etc...
a2ensite bwapp

service apache2 restart

# Make the samurai user auto-login
# TODO: Make this optional since most people really should login :)
if [ ! -d "/etc/lightdm/lightdm.conf.d" ]
then
  mkdir /etc/lightdm/lightdm.conf.d
fi
echo "[SeatDefaults]" > /etc/lightdm/lightdm.conf.d/50-myconfig.conf
echo autologin-user=samurai >> /etc/lightdm/lightdm.conf.d/50-myconfig.conf

# Setup the background
# TODO: This doesn't seem to be working... not sure why
# su - samurai -c 'kwriteconfig --file plasma-appletsrc --group Containments --group 8 --group Wallpaper --group image --key wallpaper /opt/samurai/samurai-background.png'
# su - samurai -c 'gsettings set org.gnome.desktop.background picture-uri file:////opt/samurai/samurai-background.png'
# TODO: Reload plasma to see desktop background.  Maybe not necessary if we just do a reboot?
# pkill plasma
# plasma-desktop &

echo "Additional manual (for now) installation steps:"
echo "- Set the background desktop image to /opt/samurai/samurai-background.png"
echo "- Visit http://bWAPP/install.php and run the install"
echo "- Visit http://mutillidae and reset the database"
echo "- Visit http://dvwa/setup.php and reset the database"