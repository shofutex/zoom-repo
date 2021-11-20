# zoom-repo
Sets up automatic updates for Zoom on ubuntu

Zoom on debian doesn't automatically update.
This script will pull the latest zoom debian file, check it's 
signature, and update a custom debian repository

Requires a debian repository format as follows:
 /var/www/html/debian
 debian/KEYS.gpg - your repo's key
 pools/main/z/zoom_amd64.deb
 dists/stable/main/binary-amd64/
 
This script will make the Packages and Release files

Requires apt-ftparchive and dpkg-sig
Also requires you import the Zoom signing key into your GnuPG keyring

/var/log/zoom_update.log should be writable by this user


The following needs to be added to your apt sources:
deb [arch=amd64] http://<your_hostname/debian stable main

You need the following in your .gnupg/gpg.conf
cert-digest-algo SHA512
digest-algo SHA512

This will prevent apt from complaining that you have insufficient security
