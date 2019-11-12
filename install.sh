#!/bin/bash

set -e

yesterdays_date=$(date -d "yesterday" +%Y/%m/%d)

# setting packan to use yesterdays packages
echo 'Server = https://archive.archlinux.org/repos/'"${yesterdays_date}"'/$repo/os/$arch' > /etc/pacman.d/mirrorlist

# adding cloudflare nameservers
echo "nameserver 1.1.1.1" > /etc/resolv.conf || true
echo "nameserver 1.0.0.1" >> /etc/resolv.conf || true

# refresh gpg keys
gpg --refresh-keys

# initialise key for pacman and populate keys 
pacman-key --init && pacman-key --populate archlinux

# force use of protocol http and ipv4 only for keyserver (defaults to hkp)
echo "no-greeting" > /etc/pacman.d/gnupg/gpg.conf
echo "no-permission-warning" >> /etc/pacman.d/gnupg/gpg.conf
echo "lock-never" >> /etc/pacman.d/gnupg/gpg.conf
echo "keyserver hkp://ipv4.pool.sks-keyservers.net" >> /etc/pacman.d/gnupg/gpg.conf
echo "keyserver-options timeout=10" >> /etc/pacman.d/gnupg/gpg.conf

# force pacman db refresh and install packages
pacman -Sy sed vim grep wget --noconfirm

# configure pacman to not extract certain folders from packages being installed
# this is done as we strip out locale, man, docs etc when we build the arch-scratch image
sed -i '\~\[options\]~a # Do not extract the following folders from any packages being installed\n'\
'NoExtract   = usr/share/locale* !usr/share/locale/en* !usr/share/locale/locale.alias\n'\
'NoExtract   = usr/share/doc*\n'\
'NoExtract   = usr/share/man*\n'\
'NoExtract   = usr/share/gtk-doc*\n' \
/etc/pacman.conf

# install base
# pacman -S base --noconfirm

# Updating packages currently installed
pacman -Syu --noconfirm

# create locale
echo en_US.UTF-8 UTF-8 > /etc/locale.gen
locale-gen
echo LANG="en_US.UTF-8" > /etc/locale.conf

# find latest tini release tag from github
curl --connect-timeout 5 --max-time 600 --retry 5 --retry-delay 0 --retry-max-time 60 -o /tmp/tini_release_tag -L https://github.com/krallin/tini/releases
tini_release_tag=$(cat /tmp/tini_release_tag | grep -P -o -m 1 '(?<=/krallin/tini/releases/tag/)[^"]+')

# download tini, used to do graceful exit when docker stop issued and correct reaping of zombie processes.
curl --connect-timeout 5 --max-time 600 --retry 5 --retry-delay 0 --retry-max-time 60 -o /usr/bin/tini -L "https://github.com/krallin/tini/releases/download/${tini_release_tag}/tini-amd64" && chmod +x /usr/bin/tini

# general cleanup
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