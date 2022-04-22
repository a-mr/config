#!/usr/bin/env bash

# Basic packages: console & simple X11 tools

. $HOME/.functions.sh

INS="red_command sudo apt-get install -y $1"

$INS zsh zsh-autosuggestions mosh libfile-mimeinfo-perl # for mimeopen
$INS crudini dos2unix gawk aptitude python3-tk vim-gtk3 konsole kinit kio kio-extras kded5 ht vifm
# lfhex - no ubuntu

#hardware tools:
$INS msr-tools lshw pciutils dmidecode
# file systems
$INS exfat-utils exfat-fuse sshfs archivemount jmtpfs partitionmanager nfs-common nfs-kernel-server

#networking
$INS iftop ethtool net-tools traceroute

$INS curl wget

#internet
$INS links elinks lynx w3m w3m-img wvdial

#archiving
$INS unace unrar zip unzip p7zip-full sharutils uudeview mpack lhasa arj cabextract file-roller

if cat /etc/locale.gen |grep -v "^#"|grep -i ru_RU.UTF-8; then
    aux_echo locale seems to be installed
else
    sudo sh -c 'echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen'
    red_command sudo locale-gen
fi

if cat /etc/locale.gen |grep -v "^#"|grep -i en_DK.UTF-8; then
    aux_echo locale seems to be installed
else
    sudo sh -c 'echo "en_DK.UTF-8 UTF-8" >> /etc/locale.gen'
    red_command sudo locale-gen
fi

#search absent files
$INS apt-file
sudo apt-file update

##install all firmware
#if [[ `os_distribution` = "debian" ]]; then
#	$INS `apt-file --package-only search /lib/firmware/`
#fi
