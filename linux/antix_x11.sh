#!/usr/bin/env bash

# Extended packages: X11 mainly and exotic user-space console tools
. $HOME/.functions.sh

INS="red_command sudo apt-get install -y $1"

add-apt-repository ppa:mozillateam/ppa
$INS firefox-esr

# use eom (eye of mate) as image viewer
$INS filezilla eom webp
#fonts
$INS gsfonts gsfonts-x11 fonts-arphic-ukai fonts-arphic-uming fonts-ipafont-mincho fonts-ipafont-gothic fonts-unfonts-core xfonts-terminus ttf-mscorefonts-installer fonts-liberation2 fonts-firacode unifont fonts-ebgaramond fonts-ebgaramond-extra

#misc
$INS suckless-tools xsel xclip wmctrl keynav xcalib xdelta3 klavaro gpick baobab safeeyes xprintidle

# search files
$INS recoll libimage-exiftool-perl python3-chm python3-mutagen unrtf untex lyx python3-rarfile xsltproc

$INS ibus-table-latex

$INS psutils xournal xsane hplip-gui
#pdf manipulation:
$INS atril texlive-extra-utils texlive-latex-recommended pdftk

# x tools
$INS xbindkeys xvkbd xdotool gkrellm gkrellm-cpufreq

#doc reader
$INS gv fbreader djview4 xchm okular okular-extra-backends libqca-qt5-2-plugins qt5-style-kvantum qt5-style-kvantum-themes

#mulit-MEDIA&sound
$INS vlc mplayer smplayer ffmpeg handbrake moc xine-ui rhythmbox audacity pasystray pavucontrol guvcview cheese mediainfo soundconverter

# graphics
$INS gimp inkscape dia

#torrents & p2p
$INS transmission deluge

