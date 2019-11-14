#!/bin/bash

set -e

yesterdays_date=$(date -d "yesterday" +%Y/%m/%d)

# setting packan to use yesterdays packages
echo -e "\e[32m[INFO] Setting pacman dat to yesterday\e[0m"
echo 'Server = https://archive.archlinux.org/repos/'"${yesterdays_date}"'/$repo/os/$arch' > /etc/pacman.d/mirrorlist

# adding cloudflare nameservers
echo -e "\e[32m[INFO] Adding cloudflare dns\e[0m"
echo "nameserver 1.1.1.1" > /etc/resolv.conf || true
echo "nameserver 1.0.0.1" >> /etc/resolv.conf || true

# refresh gpg keys
echo -e "\e[32m[INFO] Refreshing gpg keys\e[0m"
gpg --refresh-keys

# initialise key for pacman and populate keys 
echo -e "\e[32m[INFO] Initializing pacman\e[0m"
pacman-key --init && pacman-key --populate archlinux

# force use of protocol http and ipv4 only for keyserver (defaults to hkp)
echo -e "\e[32m[INFO] Forcing use of http and ipv4 for the keyserver\e[0m"
echo "no-greeting" > /etc/pacman.d/gnupg/gpg.conf
echo "no-permission-warning" >> /etc/pacman.d/gnupg/gpg.conf
echo "lock-never" >> /etc/pacman.d/gnupg/gpg.conf
echo "keyserver hkp://ipv4.pool.sks-keyservers.net" >> /etc/pacman.d/gnupg/gpg.conf
echo "keyserver-options timeout=10" >> /etc/pacman.d/gnupg/gpg.conf

# force pacman db refresh and install packages
echo -e "\e[32m[INFO] Refresh pacman db and install packages\e[0m"
pacman -Sy sed vi gzip --noconfirm

# configure pacman to not extract certain folders from packages being installed
# this is done as we strip out locale, man, docs etc when we build the arch-scratch image
echo -e "\e[32m[INFO] Configuring pacman extraction\e[0m"
sed -i '\~\[options\]~a # Do not extract the following folders from any packages being installed\n'\
'NoExtract   = usr/share/locale* !usr/share/locale/en* !usr/share/locale/locale.alias\n'\
'NoExtract   = usr/share/doc*\n'\
'NoExtract   = usr/share/man*\n'\
'NoExtract   = usr/share/gtk-doc*\n' \
/etc/pacman.conf

# remove unneeded packages
# echo -e "\e[32m[INFO] Removing bloat\e[0m"
# pacman -Rsc e2fsprogs --noconfirm

# Updating packages currently installed
echo -e "\e[32m[INFO] Performing update\e[0m"
pacman -Syu --noconfirm

# create locale
echo -e "\e[32m[INFO] Generate locale\e[0m"
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# general cleanup
echo -e "\e[32m[INFO] Cleanup\e[0m"
yes|pacman -Scc
pacman --noconfirm -Rns $(pacman -Qtdq) 2> /dev/null || true
rm -rf /usr/share/locale/*
rm -rf /usr/share/man/*
rm -rf /usr/share/gtk-doc/*
rm -rf /tmp/*

# additional cleanup for base only
rm -rf /root/*
rm -rf /var/cache/pacman/pkg/*
rm -rf /README