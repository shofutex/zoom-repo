#!/bin/bash
#
# Zoom on debian doesn't automatically update.
# This script will pull the latest zoom debian file, check it's 
# signature, and update a custom debian repository
#
# Requires a debian repository format as follows:
# /var/www/html/debian
# debian/KEYS.gpg - your repo's key
# pools/main/z/zoom_amd64.deb
# dists/stable/main/binary-amd64/
#
# This script will make the Packages and Release files
#
# Requires apt-ftparchive and dpkg-sig
# Also requires you import the Zoom signing key into your GnuPG keyring
#
# /var/log/zoom_update.log should be writable by this user
#
#
# The following needs to be added to your apt sources:
# deb [arch=amd64] http://<your_hostname/debian stable main
#
# You need the following in your .gnupg/gpg.conf
# cert-digest-algo SHA512
# digest-algo SHA512
#
# This will prevent apt from complaining that you have insufficient security
#
# Running this file requires passing your signing-key id as an argument
cd /var/www/html/debian
wget https://zoom.us/client/latest/zoom_amd64.deb -q -O /tmp/zoom_amd64.deb
if [ "$(md5sum -c ~/zoom.md5)" != "/tmp/zoom_amd64.deb: OK" ]; then
    echo "$(date +"%D"): Updating zoom package repo" | tee -a /var/log/zoom_update.log

    if [ $(dpkg-sig --verify /tmp/zoom_amd64.deb | grep GOODSIG | wc -l) -eq 1 ]; then 

        # Create a new md5 hash and move the deb file to the repo
        md5sum /tmp/zoom_amd64.deb > ~/zoom.md5
        mv /tmp/zoom_amd64.deb pool/main/z/
        
        # This will give off some warnings, but it's usable
        apt-ftparchive packages . > dists/stable/main/binary-amd64/Packages
        cd dists/stable
        
        # Ubuntu software updater will be weird without these pieces
        apt-ftparchive -oAPT::FTPArchive::Release::Suite=stable -oAPT::FTPArchive::Release::Codename=stable -oAPT::FTPArchive::Release::Architectures=amd64 -oAPT::FTPArchive::Release::Components=main release . > Release

        # Create the signed Release files
        gpg --default-key $1 --pinentry-mode loopback --passphrase-file ~/zoom_passphrase.txt --batch --yes -abs -o Release.gpg Release
        gpg --default-key $1 --pinentry-mode loopback --passphrase-file ~/zoom_passphrase.txt --batch --yes --clearsign -o InRelease Release

        echo "$(date +"%D"): Completed updating zoom package repo" | tee -a /var/log/zoom_update.log

    else
        echo "$(date +"%D"): ERROR bad package signature" | tee -a /var/log/zoom_update.log
    fi

else
    echo "$(date +"%D"): No updates needed" | tee -a /var/log/zoom_update.log
    rm /tmp/zoom_amd64.deb
fi
