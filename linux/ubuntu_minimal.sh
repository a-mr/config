#!/usr/bin/env bash

. $HOME/.functions.sh


if [[ `os_distribution` = "ubuntu" ]]; then
    blue_echo ubuntu detected
else
    red_echo unknown distro
    exit 1
fi

INS="red_command apt-get install -y $1"

#gui&others
$INS arc-theme xfwm4-themes

$INS vim-gtk crudini gawk hibernate aptitude ssh ssh-askpass-gnome gocryptfs

#server
$INS nfs-kernel-server portmap

$INS mc zsh screen tmux tree parallel sshpass pwgen xclip rxvt-unicode x11-apps xbitmaps gpm easystroke
# Sys: burning & firewall & others
$INS brasero gufw gparted testdisk smartmontools mtools smart-notifier
# hardware & monitoring utilities
$INS gkrellm lm-sensors hardinfo gsmartcontrol
$INS exfat-utils exfat-fuse sshfs archivemount jmtpfs davfs2

$INS iftop htop ethtool blueman traceroute udisks2

#misc
$INS rlwrap suckless-tools xsel keynav xcalib xdelta3 ghex klavaro gpick

# search files
$INS recoll libimage-exiftool-perl pstotext python-chm python-mutagen unrtf untex

##$INS texlive-full biber pybtex hevea a2ps html2ps referencer pybliographer cb2bib kbibtex
#for latex2man, julia build, etc.
$INS texlive texlive-formats-extra texlive-metapost texlive-extra-utils gfortran

#clipboard manager
$INS clipit ibus-table-latex

$INS curl wget unison-gtk

#$INS ocaml-core libocamlgsl-ocaml liblablgtk2-ocaml-dev 


#add-apt-repository ppa:staticfloat/julianightlies
#add-apt-repository ppa:staticfloat/julia-deps
#$INS julia ##fp-compiler racket

$INS lua5.1 lua5.2 luajit luarocks

$INS jupyter
$INS python-pip python-scipy python-matplotlib python-numpy pylint3

#dep?
$INS fonts-mathjax libjs-mathjax libpgm-dev libzmq5 python-pexpect python-pexpect-doc python-simplegeneric python-zmq
#pip install ipython jinja2 tornado pyzmq sphinx

$INS psutils xournal xsane sdcv goldendict

#internet
$INS elinks w3m-img wvdial surf

$INS firefox thunderbird chromium-browser konqueror

# x tools
$INS xbindkeys xvkbd 

#Version control, install all:
$INS cvs subversion mercurial tortoisehg hg-fast-export bzr git-core gitk gitweb darcs

#doc reader
$INS gv fbreader calibre djview4 xchm okular-extra-backends okular-mobile

#Essential tools for compiling from sources
$INS build-essential checkinstall cdbs devscripts dh-make fakeroot libxml-parser-perl check avahi-daemon valgrind clang clang-format exuberant-ctags cppcheck libboost-test-dev

#
$INS m4 libev-dev

#x dev
$INS xutils libx11-dev libxext-dev build-essential \
            xautomation xinput xserver-xorg-dev xutils-dev libtool \
            autoconf flex bison autoconf2.13 freeglut3-dev xorg-dev

INSB="red_command apt-get build-dep -y $1"
#dev for opengl, gtk/gnome
$INSB trackballs extremetuxracer nautilus

#other
$INS llvm libwxgtk3.0-dev libbz2-dev libgtk2.0-dev libqt4-dev libqt4-opengl-dev libqtwebkit4 libqt4-declarative libqt4-declarative-particles libboost-dev

# build systems
$INS cmake scons
# other
$INS libgdbm-dev libgsl0-dev libprotobuf-dev protobuf-compiler python-protobuf libpurple-dev libgcrypt-dev libwebp-dev libjson-glib-dev

#Java runtime environment
$INS icedtea-netx icedtea-plugin

#mulit-MEDIA&sound
$INS vlc mplayer smplayer youtube-dl ffmpeg handbrake moc xine-ui rhythmbox audacity pasystray pavucontrol guvcview cheese
if [[ `os_distribution` = "ubuntu" ]]; then
	$INS mediainfo 
fi

#fonts
$INS gsfonts gsfonts-x11 fonts-arphic-ukai fonts-arphic-uming fonts-ipafont-mincho fonts-ipafont-gothic fonts-unfonts-core xfonts-terminus ttf-mscorefonts-installer

#wine
$INS wine-stable

#archiving
$INS unace unrar zip unzip p7zip-full sharutils uudeview mpack lhasa arj cabextract file-roller

# messaging
$INS telegram-desktop pidgin pidgin-sipe pidgin-skype pidgin-latex pidgin-plugin-pack

if [[ `os_distribution` = "ubuntu" ]]; then
	$INS lsb-core 
fi

# graphics
$INS gimp gimp-gmic inkscape

#torrents & p2p
$INS transmission 

#converters
$INS python-plastex pandoc antiword unoconv writer2latex

if [[ `os_distribution` = "ubuntu" ]]; then
$INS re firefox-locale-ru thunderbird-locale-ru libreoffice-l10n-ru
fi
$INS enca aspell-ru myspell-ru mythes-ru ##texlive-doc-ru xxkb 

####################### Proprietary ###########################################
# skype

$INS libgconf-2-4
wget https://go.skype.com/skypeforlinux-64.deb
red_command dpkg -i skypeforlinux-64.deb
rm -f skypeforlinux-64.deb

wget -O code.deb "https://go.microsoft.com/fwlink/?LinkID=760868"
red_command dpkg -i code.deb
rm -f code.deb

#viber 05.05.2018 FAILS to work because of dependencies on libcurl3
wget http://download.cdn.viber.com/cdn/desktop/Linux/viber.deb
red_command dpkg -i viber.deb
rm -f viber.deb

#search absent files
$INS apt-file
red_command apt-file update

uncomment ru_RU.UTF-8 /etc/locale.gen
uncomment en_DK.UTF-8 /etc/locale.gen
red_command locale-gen

