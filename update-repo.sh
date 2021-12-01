#!/bin/bash
#
cd /var/www/html/debian

date=$(ls -lh --time-style=long-iso /var/www/html/debian/dists/stable/Release | awk '{print $6" "$7}')

updates=$(find /var/www/html/debian/pool/ -newermt "$date" | wc -l)

if [ $updates -ne 0 ]; then
    echo "$(date +"%D"): Detected new packages.  Updating package repo" | tee -a /var/log/zoom_update.log
        
    # This will give off some warnings, but it's usable
    apt-ftparchive packages . > dists/stable/main/binary-amd64/Packages
    dpkg-scanpackages -a all . > dists/stable/main/binary-all/Packages
    cd dists/stable
        
    # Ubuntu software updater will be weird without these pieces
    apt-ftparchive -oAPT::FTPArchive::Release::Suite=stable -oAPT::FTPArchive::Release::Codename=stable -oAPT::FTPArchive::Release::Architectures=amd64,all -oAPT::FTPArchive::Release::Components=main release . > Release
    
    # Create the signed Release files
    gpg --default-key $1 --pinentry-mode loopback --passphrase-file ~/zoom_passphrase.txt --batch --yes -abs -o Release.gpg Release
    gpg --default-key $1 --pinentry-mode loopback --passphrase-file ~/zoom_passphrase.txt --batch --yes --clearsign -o InRelease Release
    
    echo "$(date +"%D"): Completed updating package repo" | tee -a /var/log/zoom_update.log

fi
