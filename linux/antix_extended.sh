#!/usr/bin/env bash

# Extended packages: X11 mainly and exotic user-space console tools
. $HOME/.functions.sh

INS="red_command apt-get install -y $1"

$INS xfce4 xfce4-appfinder xfce4-battery-plugin xfce4-clipman-plugin xfce4-cpufreq-plugin xfce4-cpugraph-plugin xfce4-diskperf-plugin xfce4-fsguard-plugin xfce4-genmon-plugin xfce4-mailwatch-plugin xfce4-mount-plugin xfce4-notes-plugin xfce4-panel xfce4-quicklauncher-plugin xfce4-screenshooter-plugin xfce4-sensors-plugin xfce4-smartbookmark-plugin xfce4-systemload-plugin xfce4-terminal xfce4-verve-plugin xfce4-wavelan-plugin xfce4-weather-plugin thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman gvfs gvfs-backends lightdm lightdm-gtk-greeter policykit-1 elogind xfce4-power-manager-plugins xfce4-whiskermenu-plugin xfce4-xkb-plugin xfwm4-themes

# use eom (eye of mate) as image viewer
$INS chromium filezilla spacefm eom webp
#fonts
$INS gsfonts gsfonts-x11 fonts-arphic-ukai fonts-arphic-uming fonts-ipafont-mincho fonts-ipafont-gothic fonts-unfonts-core xfonts-terminus ttf-mscorefonts-installer fonts-liberation2 fonts-firacode unifont

#misc
$INS rlwrap suckless-tools xsel keynav xcalib xdelta3 gnome-search-tool klavaro gpick baobab

# search files
$INS recoll libimage-exiftool-perl pstotext python-chm python-mutagen unrtf untex

#clipboard manager
$INS parcellite ibus-table-latex

$INS julia lua5.1 lua5.3 luajit

$INS jupyter-notebook
$INS psutils xournal xsane
#pdf manipulation:
$INS texlive-extra-utils texlive-latex-recommended pdftk
$INS sdcv goldendict

# x tools
$INS xbindkeys xvkbd xdotool gkrellm gkrellm-cpufreq

#doc reader
$INS gv fbreader djview4 xchm

#mulit-MEDIA&sound
$INS vlc mplayer smplayer ffmpeg handbrake moc xine-ui rhythmbox audacity pasystray pavucontrol guvcview cheese mediainfo soundconverter

#bluetooth headset
$INS pulseaudio pulseaudio-module-bluetooth pavucontrol bluez-firmware blueman

# messaging
$INS pidgin pidgin-sipe pidgin-skype pidgin-latex

# graphics
$INS gimp inkscape dia

#torrents & p2p
$INS transmission 

#converters
$INS python-plastex pandoc antiword unoconv writer2latex

$INS aspell-ru myspell-ru mythes-ru

#misc
$INS fortune-mod fortunes fortunes-ru
