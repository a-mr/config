#!/usr/bin/env bash

. $HOME/.functions.sh

if [[ `os_distribution` = "debian" ]]; then
    blue_echo debian detected
elif [[ `os_distribution` = "ubuntu" ]]; then
    blue_echo ubuntu detected
else
    red_echo unknown distro
fi

# For debian testing
INS="red_command apt-get install -y --force-yes"











$INS crudini
$INS gawk hibernate

#$INS gnome
#red_command tasksel install desktop
$INS gnome
if [[ `os_distribution` = "debian" ]]; then
red_command tasksel install print-server
red_command tasksel install ssh-server
fi

$INS ssh ssh-askpass-gnome

#server
$INS nfs-kernel-server portmap

$INS mc spacefm-gtk3 gkrellm conky apcupsd zsh tcsh screen tmux tree parallel lm-sensors sshpass pwgen xclip xterm konsole rxvt-unicode xfce4-terminal roxterm x11-apps xbitmaps lftp gpm
$INS exfat-utils exfat-fuse sshfs
#editors/IDE
$INS vim-gtk vim-latexsuite vim-pathogen emacs scite jedit  
#eclipse-cdt 

$INS iftop ethtool blueman traceroute
#misc
$INS rlwrap suckless-tools xsel keynav xcalib xdelta3 gnome-search-tool lfhex kruler klavaro gtypist
$INS texlive-full biber pybtex hevea a2ps html2ps referencer pybliographer cb2bib kbibtex
#clipboard manager
$INS glipper parcellite ibus-table-latex fcitx-table-latex fcitx-tools 
$INS curl wget unison-gtk
#$INS ocaml-core libocamlgsl-ocaml liblablgtk2-ocaml-dev 
if [[ `os_distribution` = "ubuntu" ]]; then
    add-apt-repository ppa:staticfloat/julianightlies
    add-apt-repository ppa:staticfloat/julia-deps
    apt-get update
fi
$INS julia fp-compiler racket
$INS lua5.1 lua5.2 luajit luarocks
#$INS ipython ipython-notebook ipython-qtconsole 
$INS python-pip python-scipy python-matplotlib python-numpy
#dep?
$INS fonts-mathjax libjs-mathjax libpgm-5.1-0 libzmq3 python-pexpect python-pexpect-doc python-simplegeneric python-zmq
pip install ipython jinja2 tornado pyzmq sphinx

if [[ `os_distribution` = "ubuntu" ]]; then
    $INS kubuntu-desktop
else
    $INS kde-standard
fi
$INS xfce4 icewm awesome subtle i3 fvwm lxde
$INS lightdm
update-alternatives --set x-session-manager /usr/bin/xfce4-session
#sed -i 's/^Theme=.*/Theme=\/usr\/share\/kde4\/apps\/kdm\/themes\/oxygen/g' /etc/kde4/kdm/kdmrc
echo /usr/sbin/lightdm > /etc/X11/default-display-manager
if file /usr/bin/gdmflexiserver|grep ELF; then
    yellow_echo change /usr/bin/gdmflexiserver to script
    mv /usr/bin/gdmflexiserver /usr/bin/gdmflexiserver.orig
    cp gdmflexiserver /usr/bin/
elif grep dm-tool /usr/bin/gdmflexiserver; then
    aux_echo /usr/bin/gdmflexiserver is correct script already
else
    yellow_echo replace /usr/bin/gdmflexiserver script
    mv /usr/bin/gdmflexiserver /usr/bin/gdmflexiserver.orig
    cp gdmflexiserver /usr/bin/
fi
crudini --set /etc/lightdm/lightdm.conf SeatDefaults greeter-hide-users false
crudini --set /etc/lightdm/lightdm.conf SeatDefaults greeter-setup-script /etc/lightdm/info.sh
cp info.sh /etc/lightdm/info.sh

$INS psutils xournal xsane 
$INS sdcv stardict goldendict

$INS rednotebook 

#internet
$INS elinks lynx w3m w3m-img wvdial konqueror 
if [[ `os_distribution` = "debian" ]]; then
$INS iceweasel icedove chromium
fi
if [[ `os_distribution` = "ubuntu" ]]; then
$INS firefox thunderbird chromium-browser
fi

# x tools
$INS xbindkeys xvkbd 

#Version control:
$INS cvs subversion mercurial tortoisehg hg-fast-export bzr git-core gitk gitweb darcs kdiff3

#doc reader
$INS gv fbreader djview4 okular-extra-backends kchmviewer xchm

#Essential tools for compiling from sources
$INS build-essential gcc-doc checkinstall cdbs devscripts dh-make fakeroot libxml-parser-perl check avahi-daemon valgrind 

#
$INS m4 libev-dev

#x dev
$INS xutils libx11-dev libxext-dev build-essential \
            xautomation xinput xserver-xorg-dev xutils-dev libtool \
            autoconf flex bison autoconf2.13 freeglut3-dev xorg-dev

INSB="apt-get build-dep -y --force-yes"
#dev for opengl, gtk/gnome, kde
$INSB trackballs extremetuxracer nautilus okular k3b

#other
$INS llvm libwxgtk3.0-dev libbz2-dev libgtk2.0-dev libqt4-dev libqt4-opengl-dev libqtwebkit4 libqt4-declarative libqt4-declarative-particles libboost-dev

# build systems
$INS cmake scons
# other
$INS libgdbm-dev libgsl0-dev libprotobuf-dev protobuf-compiler python-protobuf

# fortran
$INS gfortran cernlib paw libmpfi-dev libmpfr-dev

#other physics
$INS libpythia8-dev libhepmc-dev

#ROOT
$INS root-system libroot-bindings-python-dev libroot-bindings-ruby-dev

#Java runtime environment
$INS icedtea-netx icedtea-plugin

#mulit-MEDIA&sound
$INS vlc mplayer moc xine-ui rhythmbox audacity volumeicon-alsa volti pasystray pavucontrol guvcview cheese

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
$INS kopete pidgin

# Sys: burning & firewall & others
$INS k3b brasero gufw lsb-core testdisk smartmontools smart-notifier
#gsmartcontrol 

# graphics
$INS gimp inkscape

#torrents & p2p
$INS transmission 
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
$INS re iceweasel-l10n-ru icedove-l10n-ru kde-l10n-ru libreoffice-l10n-ru
fi
if [[ `os_distribution` = "ubuntu" ]]; then
$INS re firefox-locale-ru thunderbird-locale-ru kde-l10n-ru libreoffice-l10n-ru
fi
$INS aspell-ru myspell-ru mythes-ru texlive-doc-ru xxkb 

if [[ `os_distribution` = "debian" ]]; then
fbxkb
fi

#non-interactive:
#$INS console-cyrillic 
#:-)
$INS festvox-ru
#OCR,etc
$INS tesseract-ocr-rus ocrodjvu pdf2djvu yagf libtiff-tools didjvu scantailor pdftk python-pypdf exactimage ruby-dev libmagickcore-dev libmagickwand-dev libcam-pdf-perl
if [[ `os_distribution` = "debian" ]]; then
$INS djvubind 
fi
gem install pdfbeads iconv

#install R
$INS r-cran-ggplot2 r-cran-reshape r-cran-reshape2 r-cran-mcmcpack r-cran-vgam
echo 'install.packages(c("beeswarm"),repos="http://cran.us.r-project.org");' | R --no-save

#misc.math
$INS maxima wxmaxima cantor lyx octave

####################### Proprietary ###########################################
# skype
if [[ `os_distribution` = "debian" ]]; then
#if dpkg -L skype>/dev/null; then
#    aux_echo skype already installed
#else
    wget -O skype-install.deb http://www.skype.com/go/getskype-linux-deb
    dpkg --add-architecture i386
    apt-get update
    dpkg -i skype-install.deb
    apt-get -f install -y
    rm -f skype-install.deb
#fi
fi
if [[ `os_distribution` = "ubuntu" ]]; then
echo "deb http://archive.canonical.com/ trusty partner" >> /etc/apt/sources.list
apt-get update
apt-get install skype
fi

#games
$INS qgo gnugo

#acroread, adobe flashplugin
if [[ `os_distribution` = "debian" ]]; then
apt-get remove -y gnash
$INS acroread flashplugin-nonfree
update-flashplugin-nonfree --install
fi
if [[ `os_distribution` = "ubuntu" ]]; then
$INS adobe-flashplugin
fi

if [[ `os_distribution` = "debian" ]]; then
TZ="Europe/Moscow"
echo $TZ > /etc/timezone
cp /usr/share/zoneinfo/$TZ /etc/localtime
fi

#search absent files
$INS apt-file
apt-file update

