#!/bin/bash

. $HOME/.functions.sh

if [[ `os_distribution` = "debian" ]]; then
    blue_echo debian detected
elif [[ `os_distribution` = "ubuntu" ]]; then
    blue_echo ubuntu detected
else
    red_echo unknown distro
    exit 1
fi

# For debian testing
INS="red_command apt-get install $1"











$INS crudini
$INS gawk hibernate aptitude

if [[ `os_distribution` = "debian" ]]; then
$INS --allow-unauthenticated deb-multimedia-keyring
red_command tasksel install print-server
red_command tasksel install ssh-server
fi

$INS ssh ssh-askpass-gnome

#server
$INS nfs-kernel-server portmap

$INS mc spacefm-gtk3 gkrellm conky apcupsd zsh tcsh screen tmux tree parallel lm-sensors sshpass pwgen xclip xterm rxvt-unicode xfce4-terminal x11-apps xbitmaps lftp gpm
$INS exfat-utils exfat-fuse sshfs archivemount
if [[ `os_distribution` = "debian" ]]; then
	$INS jmtpfs
fi
if [[ `os_distribution` = "ubuntu" ]]; then
	$INS mtpfs
fi
#editors/IDE
$INS vim-gtk vim-latexsuite vim-pathogen emacs scite jedit  
#eclipse-cdt 

$INS iftop ethtool blueman traceroute udisks2
#misc
$INS rlwrap suckless-tools xsel keynav xcalib xdelta3 gnome-search-tool lfhex klavaro gpick
# search files
$INS recoll libimage-exiftool-perl pstotext python-chm python-mutagen unrtf untex
##$INS texlive-full biber pybtex hevea a2ps html2ps referencer pybliographer cb2bib kbibtex
#clipboard manager
$INS glipper parcellite ibus-table-latex fcitx-table-latex fcitx-tools 
$INS curl wget unison-gtk
#$INS ocaml-core libocamlgsl-ocaml liblablgtk2-ocaml-dev 
if [[ `os_distribution` = "ubuntu" ]]; then
    add-apt-repository ppa:staticfloat/julianightlies
    add-apt-repository ppa:staticfloat/julia-deps
    apt-get update
fi
$INS julia ##fp-compiler racket
$INS lua5.1 lua5.2 luajit luarocks
#$INS ipython ipython-notebook ipython-qtconsole 
$INS python-pip python-scipy python-matplotlib python-numpy
#dep?
$INS fonts-mathjax libjs-mathjax libpgm-dev libzmq5 python-pexpect python-pexpect-doc python-simplegeneric python-zmq
pip install ipython jinja2 tornado pyzmq sphinx

$INS xfce4 xfce4-goodies
##$INS lightdm
##update-alternatives --set x-session-manager /usr/bin/xfce4-session
###sed -i 's/^Theme=.*/Theme=\/usr\/share\/kde4\/apps\/kdm\/themes\/oxygen/g' /etc/kde4/kdm/kdmrc
##echo /usr/sbin/lightdm > /etc/X11/default-display-manager
##if file /usr/bin/gdmflexiserver|grep ELF; then
##    yellow_echo change /usr/bin/gdmflexiserver to script
##    mv /usr/bin/gdmflexiserver /usr/bin/gdmflexiserver.orig
##    cp gdmflexiserver /usr/bin/
##elif grep dm-tool /usr/bin/gdmflexiserver; then
##    aux_echo /usr/bin/gdmflexiserver is correct script already
##else
##    yellow_echo replace /usr/bin/gdmflexiserver script
##    mv /usr/bin/gdmflexiserver /usr/bin/gdmflexiserver.orig
##    cp gdmflexiserver /usr/bin/
##fi
##crudini --set /etc/lightdm/lightdm.conf SeatDefaults greeter-hide-users false
##crudini --set /etc/lightdm/lightdm.conf SeatDefaults greeter-setup-script /etc/lightdm/info.sh
##cp info.sh /etc/lightdm/info.sh

$INS psutils xournal xsane 
$INS sdcv qstardict goldendict

$INS rednotebook 

#internet
$INS elinks lynx w3m w3m-img wvdial surf
if [[ `os_distribution` = "debian" ]]; then
$INS iceweasel icedove chromium
fi
if [[ `os_distribution` = "ubuntu" ]]; then
$INS firefox thunderbird chromium-browser
fi

# x tools
$INS xbindkeys xvkbd 

#Version control:
$INS cvs subversion mercurial tortoisehg hg-fast-export bzr git-core gitk gitweb darcs

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

#other
$INS llvm libwxgtk3.0-dev libbz2-dev libgtk2.0-dev libqt4-dev libqt4-opengl-dev libqtwebkit4 libqt4-declarative libqt4-declarative-particles libboost-dev

# build systems
$INS cmake scons
# other
$INS libgdbm-dev libgsl0-dev libprotobuf-dev protobuf-compiler python-protobuf

### fortran
##$INS gfortran cernlib paw libmpfi-dev libmpfr-dev
##
###other physics
##$INS libpythia8-dev libhepmc-dev
##
###ROOT
##$INS root-system libroot-bindings-python-dev libroot-bindings-ruby-dev

#Java runtime environment
$INS icedtea-netx icedtea-plugin

#mulit-MEDIA&sound
$INS vlc mplayer ffmpeg handbrake moc xine-ui rhythmbox audacity pasystray pavucontrol guvcview cheese
if [[ `os_distribution` = "ubuntu" ]]; then
	$INS mediainfo 
fi

#$INS libxine1-ffmpeg gxine mencoder mpeg2dec vorbis-tools id3v2 mpg321 mpg123 libflac++6 ffmpeg totem-mozilla icedax tagtool easytag id3tool lame nautilus-script-audio-convert libmad0 libjpeg-progs libquicktime2 flac faac faad sox ffmpeg2theora libmpeg2-4 uudeview flac libmpeg3-1 mpeg3-utils mpegdemux liba52-0.7.4-dev

#$INS gstreamer0.10-plugins-bad gstreamer0.10-ffmpeg gstreamer0.10-plugins-ugly smplayer

#FLASH plugin ?
#fonts
$INS gsfonts gsfonts-x11 fonts-arphic-ukai fonts-arphic-uming fonts-ipafont-mincho fonts-ipafont-gothic fonts-unfonts-core xfonts-terminus ttf-mscorefonts-installer

#flashplugin-installer

#wine
$INS wine

#archiving
$INS unace unrar zip unzip p7zip-full sharutils uudeview mpack lhasa arj cabextract file-roller

# messaging
$INS pidgin pidgin-sipe pidgin-skype pidgin-latex

# Sys: burning & firewall & others
$INS brasero gufw gparted testdisk smartmontools smart-notifier
if [[ `os_distribution` = "ubuntu" ]]; then
	$INS lsb-core 
fi
if [[ `os_distribution` = "debian" ]]; then
	$INS lsb-release
fi
#gsmartcontrol 

# graphics
$INS gimp inkscape

#torrents & p2p
##$INS transmission 
#sh -c "$(curl -fsSL http://debian.yeasoft.net/add-btsync-repository.sh)"
#$INS btsync-gui

#converters
$INS python-plastex pandoc antiword unoconv writer2latex

if cat /etc/locale.gen |grep -v "^#"|grep ru_RU.UTF-8; then
    aux_echo locale seems to be installed
else
    echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
    red_command locale-gen
fi

if [[ `os_distribution` = "debian" ]]; then
$INS konwert iceweasel-l10n-ru icedove-l10n-ru libreoffice-l10n-ru
# $INS re
fi
if [[ `os_distribution` = "ubuntu" ]]; then
$INS re firefox-locale-ru thunderbird-locale-ru libreoffice-l10n-ru
fi
$INS aspell-ru myspell-ru mythes-ru ##texlive-doc-ru xxkb 

###non-interactive:
###$INS console-cyrillic 
###:-)
##$INS festvox-ru
###OCR,etc
##$INS tesseract-ocr-rus ocrodjvu pdf2djvu yagf libtiff-tools didjvu scantailor pdftk python-pypdf exactimage ruby-dev libmagickcore-dev libmagickwand-dev libcam-pdf-perl
##if [[ `os_distribution` = "debian" ]]; then
##$INS djvubind 
##fi
##gem install pdfbeads iconv

###install R
##$INS r-cran-ggplot2 r-cran-reshape r-cran-reshape2 r-cran-mcmcpack r-cran-vgam
##echo 'install.packages(c("beeswarm"),repos="http://cran.us.r-project.org");' | R --no-save
##
###misc.math
##$INS maxima wxmaxima cantor lyx octave

####################### Proprietary ###########################################
# skype
if [[ `os_distribution` = "debian" ]]; then
if dpkg -L skype>/dev/null; then
    aux_echo skype already installed
else
    wget -O skype-install.deb http://www.skype.com/go/getskype-linux-deb
    dpkg --add-architecture i386
    apt-get update
    dpkg -i skype-install.deb
    apt-get -f install $1
    rm -f skype-install.deb
fi
fi
if [[ `os_distribution` = "ubuntu" ]]; then
echo "deb http://archive.canonical.com/ trusty partner" >> /etc/apt/sources.list
apt-get update
apt-get install skype
fi

#games
##$INS qgo gnugo

#acroread, adobe flashplugin
if [[ `os_distribution` = "debian" ]]; then
apt-get remove $1 gnash
$INS flashplugin-nonfree
update-flashplugin-nonfree --install
fileacr=AdbeRdr9.5.5-1_i386linux_enu.deb
wget ftp://ftp.adobe.com/pub/adobe/reader/unix/9.x/9.5.5/enu/$fileacr
#dpkg --add-architecture i386
#apt-get update
apt-get install libgtk2.0-0:i386 libxml2:i386 libstdc++6:i386
dpkg -i $fileacr
rm -f $fileacr
fi
if [[ `os_distribution` = "ubuntu" ]]; then
$INS acroread adobe-flashplugin
fi

##if [[ `os_distribution` = "debian" ]]; then
##TZ="Europe/Moscow"
##echo $TZ > /etc/timezone
##cp /usr/share/zoneinfo/$TZ /etc/localtime
##fi


#search absent files
$INS apt-file
apt-file update

#install all firmware
if [[ `os_distribution` = "debian" ]]; then
	$INS `apt-file --package-only search /lib/firmware/`
fi

#fixes
$INS gtk2-engines
if [[ `os_distribution` = "ubuntu" ]]; then
	$INS overlay-scrollbar-gtk2
fi
