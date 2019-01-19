#!/bin/bash

. $HOME/.functions.sh

# For debian testing
INS="red_command apt-get install -y $1"

#Version control:
$INS cvs subversion mercurial tortoisehg hg-fast-export bzr git gitk gitweb darcs

$INS xfce4 xfce4-appfinder xfce4-battery-plugin xfce4-clipman-plugin xfce4-cpufreq-plugin xfce4-cpugraph-plugin xfce4-diskperf-plugin xfce4-fsguard-plugin xfce4-genmon-plugin xfce4-mailwatch-plugin xfce4-mount-plugin xfce4-notes-plugin xfce4-panel xfce4-quicklauncher-plugin xfce4-screenshooter-plugin xfce4-sensors-plugin xfce4-smartbookmark-plugin xfce4-systemload-plugin xfce4-terminal xfce4-verve-plugin xfce4-wavelan-plugin xfce4-weather-plugin thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman gvfs gvfs-backends lightdm lightdm-gtk-greeter policykit-1 elogind xfce4-power-manager-plugins xfce4-whiskermenu-plugin xfce4-xkb-plugin xfwm4-themes


$INS zsh crudini gawk aptitude python-tk vim-gtk chromium konsole filezilla eog webp

#fonts
$INS gsfonts gsfonts-x11 fonts-arphic-ukai fonts-arphic-uming fonts-ipafont-mincho fonts-ipafont-gothic fonts-unfonts-core xfonts-terminus ttf-mscorefonts-installer fonts-liberation2 fonts-firacode unifont

$INS exfat-utils exfat-fuse sshfs archivemount jmtpfs

$INS iftop ethtool traceroute

#misc
$INS rlwrap suckless-tools xsel keynav xcalib xdelta3 gnome-search-tool lfhex klavaro gpick

# search files
$INS recoll libimage-exiftool-perl pstotext python-chm python-mutagen unrtf untex

#clipboard manager
$INS ibus-table-latex

$INS curl wget

$INS julia lua5.1 lua5.3 luajit

$INS jupyter-notebook
$INS psutils xournal xsane pdftk
$INS sdcv goldendict

#internet
$INS elinks lynx w3m w3m-img wvdial

# x tools
$INS xbindkeys xvkbd 

#doc reader
$INS gv fbreader djview4 xchm

#Essential tools for compiling from sources
$INS build-essential checkinstall cdbs devscripts dh-make fakeroot libxml-parser-perl check avahi-daemon valgrind 

#
$INS m4 libev-dev

#x dev
$INS xutils libx11-dev libxext-dev build-essential \
            xautomation xinput xserver-xorg-dev xutils-dev libtool \
            autoconf flex bison autoconf2.13 freeglut3-dev xorg-dev

INSB="apt-get build-dep $1"
#dev for opengl, gtk/gnome
$INSB trackballs extremetuxracer nautilus

# build systems
$INS cmake scons
# other
$INS libgdbm-dev libgsl0-dev libprotobuf-dev protobuf-compiler python-protobuf

#mulit-MEDIA&sound
$INS vlc mplayer ffmpeg handbrake moc xine-ui rhythmbox audacity pasystray pavucontrol guvcview cheese mediainfo 

#archiving
$INS unace unrar zip unzip p7zip-full sharutils uudeview mpack lhasa arj cabextract file-roller

# messaging
$INS pidgin pidgin-sipe pidgin-skype pidgin-latex

# graphics
$INS gimp inkscape dia

#torrents & p2p
$INS transmission 

#converters
$INS python-plastex pandoc antiword unoconv writer2latex

if cat /etc/locale.gen |grep -v "^#"|grep ru_RU.UTF-8; then
    aux_echo locale seems to be installed
else
    echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
    red_command locale-gen
fi

$INS aspell-ru myspell-ru mythes-ru ##texlive-doc-ru xxkb 

#search absent files
$INS apt-file
apt-file update

##install all firmware
#if [[ `os_distribution` = "debian" ]]; then
#	$INS `apt-file --package-only search /lib/firmware/`
#fi
#
##fixes
#$INS gtk2-engines
#if [[ `os_distribution` = "ubuntu" ]]; then
#	$INS overlay-scrollbar-gtk2
#fi
