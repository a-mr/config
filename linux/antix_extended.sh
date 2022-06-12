#!/usr/bin/env bash

# Extended packages: X11 mainly and exotic user-space console tools
. $HOME/.functions.sh

INS="red_command sudo apt-get install -y $1"

$INS xfce4 xfce4-appfinder xfce4-battery-plugin xfce4-clipman-plugin xfce4-cpufreq-plugin xfce4-cpugraph-plugin xfce4-diskperf-plugin xfce4-fsguard-plugin xfce4-genmon-plugin xfce4-mailwatch-plugin xfce4-mount-plugin xfce4-panel xfce4-screenshooter xfce4-sensors-plugin xfce4-smartbookmark-plugin xfce4-systemload-plugin xfce4-terminal xfce4-verve-plugin xfce4-wavelan-plugin xfce4-weather-plugin thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman gvfs gvfs-backends lightdm lightdm-gtk-greeter policykit-1 xfce4-power-manager-plugins xfce4-whiskermenu-plugin xfce4-xkb-plugin

#xpra, with all bells and whistles
#$INS python-pyinotify python-gtkglext1
#$INS --install-suggests xpra
#$INS x2goserver x2goserver-xsession x2goclient x2goserver-desktopsharing

# use eom (eye of mate) as image viewer
# $INS chromium spacefm

#clipboard manager
$INS parcellite

$INS julia lua5.1 lua5.3 luajit python3-pip

$INS jupyter-notebook
$INS sdcv goldendict

#bluetooth headset
$INS pulseaudio pulseaudio-module-bluetooth pavucontrol blueman
# bluez-firmware: not in ubuntu

# messaging
# $INS pidgin pidgin-sipe pidgin-skype pidgin-latex

wget http://download.cdn.viber.com/cdn/desktop/Linux/viber.deb
red_command sudo dpkg -i viber.deb
rm -f viber.deb

wget https://go.skype.com/skypeforlinux-64.deb
red_command sudo dpkg -i skypeforlinux-64.deb
rm -f skypeforlinux-64.deb

$INS telegram-desktop

#converters
$INS python3-plastex pandoc antiword writer2latex
#$INS python-plastex pandoc antiword unoconv writer2latex

$INS aspell-ru myspell-ru mythes-ru

$INS texlive biber texlive-bibtex-extra texlive-lang-cyrillic texlive-fonts-extra fonts-texgyre
#misc
$INS fortune-mod fortunes fortunes-ru
