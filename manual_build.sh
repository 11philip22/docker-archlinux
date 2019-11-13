#! /bin/bash

# download arch filesystem
rel_date=$(date +%Y.%m.01)                                                                                                    
wget -O archlinux.tar.gz http://archlinux.de-labrusse.fr/iso/latest/archlinux-bootstrap-${rel_date}-x86_64.tar.gz
tar --exclude=root.x86_64/etc/resolv.conf --exclude=root.x86_64/etc/hosts -xvf archlinux.tar.gz || true

# find latest tini release tag from github
curl --connect-timeout 5 --max-time 600 --retry 5 --retry-delay 0 --retry-max-time 60 -o /tmp/tini_release_tag -L https://github.com/krallin/tini/releases
tini_release_tag=$(cat /tmp/tini_release_tag | grep -P -o -m 1 '(?<=/krallin/tini/releases/tag/)[^"]+')

# download tini, used to do graceful exit when docker stop issued and correct reaping of zombie processes.
curl --connect-timeout 5 --max-time 600 --retry 5 --retry-delay 0 --retry-max-time 60 -o tini -L "https://github.com/krallin/tini/releases/download/${tini_release_tag}/tini-amd64" && chmod +x tini

docker build .