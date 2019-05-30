#!/usr/bin/env bash

# For Scientific (RHEL, CentOS) Linux 6

INS="yum install -y" 
GET=wget

$INS yum-conf-adobe yum-conf-atrpms yum-conf-elrepo yum-conf-epel yum-conf-rpmforge yum-conf-sl-other 

yum update -y --skip-broken

################################################
# Basic installation
################################################
GRINS="yum groupinstall -y"
$GRINS "KDE Desktop"
$GRINS "TeX support"
$GRINS "Development tools"
$GRINS "Additional Development"
$GRINS "Debugging Tools"
$GRINS "Technical Writing"
$GRINS "Office Suite and Productivity"
$GRINS "Server Platform Development"


$INS xterm rxvt-unicode mc Thunar thunar-volman thunar-archive-plugin gkrellm conky bash-completion zsh tcsh screen tmux lm_sensors sshpass xclip iftop nmap socat
#misc tools
$INS python-pygments jwhois rlwrap dmenu sselp vbindiff kdiff3 xdelta lshw smartmontools telnet luvcview xawtv ibus ibus-table-additional glipper parcellite #clipboard manager
$INS httpd postgresql-server postgresql-devel postgresql postfix squirrelmail mod_ssl openssl

###############
# documents editing & viewing
$INS texlive lyx tetex-tex4ht xdvik texlive-dviutils
$INS openoffice.org-writer openoffice.org-calc openoffice.org-impress openoffice.org-math
$INS catdoc AdobeReader_enu paps

# internet
$INS firefox bind-utils links lynx w3m mutt thunderbird elinks

$INS xorg-x11-xinit-session kdebase icewm WindowMaker fluxbox xscreensaver mesa-dri-drivers-experimental
$INS psutils pdfjam pdf-tools xournal xsane rednotebook
$INS qstardict

$INS cvs subversion bzr git gitk darcs unison #mercurial mercurial-hgk 
if rpm -q mercurial| grep mercurial-2.2.2; then 
	echo mercurial OK - new version; 
else 
	rpm -Uhv ftp://fr2.rpmfind.net/linux/dag/redhat/el6/en/x86_64/extras/RPMS/mercurial-2.2.2-1.el6.rfx.x86_64.rpm ftp://fr2.rpmfind.net/linux/dag/redhat/el6/en/x86_64/extras/RPMS/mercurial-hgk-2.2.2-1.el6.rfx.x86_64.rpm
fi

if rpm -q idle3-tools | grep idle3-tools-0.9.1; then
    echo idle3-tools OK - newest version; 
else
  rpm -ihv http://centos.alt.ru/repository/centos/6/x86_64/idle3-tools-0.9.1-1.el6.x86_64.rpm
fi

$INS ntfs-3g ntfsprogs fuse-exfat exfat-utils

$INS gv xpdf fbreader djvulibre djview4 kdegraphics kchmviewer xchm feh

$INS java

#editors/IDE 
$INS vim nano emacs xemacs nedit gedit
#html
$INS kdewebdev bluefish
#MEDIA
$INS mplayer smplayer #xine-ui rhythmbox kaffeine
$INS audacity #sound

$INS flash-plugin wine 

#archiving
$INS unace rar unrar zip unzip p7zip p7zip-plugins sharutils mpack arj unarj cabextract file-roller

$INS kdenetwork pidgin pidgin-latex # messaging 
$INS gimp inkscape # graphics
$INS k3b brasero # cd/dvd burning
$INS ktorrent #torrents & p2p
# for skype
$INS qt-x11.i686 qt.i686 libXScrnSaver.i686 libtiff.i686 glibc-devel.i686 sqlite3-devel.i686 sqlite-devel.i686 
#$INS skype ekiga
$INS ekiga gammu

####################################
# physics

$INS gnuplot paw cernlib cernlib-utils cernlib-devel cernlib-static geant321 patchy kuipc fann fann-devel
$INS root root-physics root-tmva root-roofit root-python root-minuit2 root-tutorial openssl098e
$INS python-matplotlib PyQwt-devel

#compatibility
$INS redhat-lsb compat-libstdc++-33.i686 compat-libstdc++-33.x86_64

#####################################
# Install packages for building
####################################
INSB="yum-builddep -y"

yum groupinstall -y 'Development tools' 'Desktop Platform Development'
$INS gcc-c++ make gperf asciidoc xmlto xmltex xmltoman xmlto-tex docbook-utils-pdf python-docutils
$INSB xscreensaver-gl-base
$INSB kdebase
$INSB k3b
$INSB ocaml
$INSB icewm
$INSB xorg-x11-server-Xorg
$INSB paw cernlib root
$INSB kaffeine
$INS llvm llvm-devel gmp-devel libffi-devel lua-devel imlib2-devel libtool-ltdl-devel qhull-devel protobuf-devel protobuf-c-devel protobuf-python protobuf-vim gdbm-devel
$INS fpc fpc-doc fpc-src #pascal for students
$INS xcb-util-devel libxcb-devel xcb-proto mysql-devel mysql++-devel mysql-devel.i686
$INS gtkglext-devel gtkglarea2-devel gtksourceview2-devel wxGTK-devel
#misc development tools
$INS valgrind scons kcachegrind graphviz graphviz-devel

###############################
# Russian language support
$INS kde-l10n-Russian hunspell-ru hyphen-ru autocorr-ru openoffice.org-langpack-ru xorg-x11-fonts-cyrillic dejavu-lgc-sans-fonts dejavu-lgc-sans-mono-fonts dejavu-lgc-serif-fonts
wget ftp://fr2.rpmfind.net/linux/sourceforge/m/ms/mscorefonts2/rpms/msttcore-fonts-installer-2.2-1.noarch.rpm
rpm -ihv msttcore-fonts-installer-2.2-1.noarch.rpm
rm msttcore-fonts-installer-2.2-1.noarch.rpm

$INS icedtea-web texlive-texmf-doc freeglut-devel gsl-devel gsl-static
$INS ImageMagick startup-notification startup-notification-devel
$INS readline readline-devel kdesdk hplip kdewebdev bluefish
$INS phoronix-test-suite #benchmark

$INS libev-devel
$INS libevent-devel

#######################################################
# Some common tweaks
#######################################################

# Install auctex
install_auctex(){
	mkdir /tmp/auctex
	cd /tmp/auctex
	cvs -z3 -d:pserver:anonymous@cvs.savannah.gnu.org:/sources/auctex co auctex
	cd auctex
	./autogen.sh
	./configure
	make
	make install
	rm -rf /tmp/auctex
}

install_auctex

echo 'install.packages(c("ggplot2","reshape","MCMCpack","VGAM"),repos="http://cran.us.r-project.org");' | R --no-save

chmod a+rx /bin/fusermount

wget "http://downloads.sourceforge.net/project/xcalib/xcalib/0.8/xcalib?r=http%3A%2F%2Fxcalib.sourceforge.net%2F&ts=1375784778&use_mirror=kaz"
chmod +x xcalib
mkdir -p /opt/bin
mv xcalib /opt/bin

