#!/bin/bash
cd /var/www/html/debian
wget https://zoom.us/client/latest/zoom_amd64.deb -O /tmp/zoom_amd64.deb
if [ "$(md5sum -c ~/zoom.md5)" != "/tmp/zoom_amd64.deb: OK" ]; then
    echo "$(date +"%D"): Updating zoom package repo" | tee -a /var/log/zoom_update.log

    if [ $(dpkg-sig --verify /tmp/zoom_amd64.deb | grep GOODSIG | wc -l) -eq 1 ]; then 

        md5sum /tmp/zoom_amd64.deb > ~/zoom.md5
        mv /tmp/zoom_amd64.deb pool/main/z/
        #apt-ftparchive packages . > Packages
        apt-ftparchive packages . dists/stable/main/binary-amd64/Packages
        cd dists/stable
        #apt-ftparchive release . > Release
        apt-ftparchive -oAPT::FTPArchive::Release::Suite=stable -oAPT::FTPArchive::Release::Codename=stable -oAPT::FTPArchive::Release::Architectures=amd64 -oAPT::FTPArchive::Release::Components=main release . > Release
        gpg --default-key F1C57AB70A1FAEE1A90C2615AEFB6151DD129BCA --passphrase signmydist --batch --yes -abs -o Release.gpg Release
        gpg --default-key F1C57AB70A1FAEE1A90C2615AEFB6151DD129BCA --passphrase signmydist --batch --yes --clearsign -o InRelease Release
        echo "$(date +"%D"): Completed updating zoom package repo" | tee -a /var/log/zoom_update.log
    else
        echo "$(date +"%D"): ERROR bad package signature" | tee -a /var/log/zoom_update.log
    fi
else
    echo "$(date +"%D"): No updates needed" | tee -a /var/log/zoom_update.log
fi
