#!/bin/bash
#
cd /var/www/html/debian
wget "$2" -q -O /var/www/html/debian/pool/main/$3
        
# This will give off some warnings, but it's usable
apt-ftparchive packages . > dists/stable/main/binary-amd64/Packages
cd dists/stable
        
# Ubuntu software updater will be weird without these pieces
apt-ftparchive -oAPT::FTPArchive::Release::Suite=stable -oAPT::FTPArchive::Release::Codename=stable -oAPT::FTPArchive::Release::Architectures=amd64 -oAPT::FTPArchive::Release::Components=main release . > Release

# Create the signed Release files
gpg --default-key $1 --pinentry-mode loopback --passphrase-file ~/zoom_passphrase.txt --batch --yes -abs -o Release.gpg Release
gpg --default-key $1 --pinentry-mode loopback --passphrase-file ~/zoom_passphrase.txt --batch --yes --clearsign -o InRelease Release

echo "$(date +"%D"): Completed updating package repo for $3" | tee -a /var/log/zoom_update.log

