#!/usr/bin/env bash

# Extended packages: X11 mainly and exotic user-space console tools
. $HOME/.functions.sh

INS="red_command sudo apt-get install -y $1"

# use eom (eye of mate) as image viewer
$INS filezilla eom webp
#fonts
$INS gsfonts gsfonts-x11 fonts-arphic-ukai fonts-arphic-uming fonts-ipafont-mincho fonts-ipafont-gothic fonts-unfonts-core xfonts-terminus ttf-mscorefonts-installer fonts-liberation2 fonts-firacode unifont

#misc
$INS rlwrap suckless-tools xsel keynav xcalib xdelta3 klavaro gpick baobab

# search files
$INS recoll libimage-exiftool-perl python-chm python-mutagen unrtf untex

$INS ibus-table-latex

$INS psutils xournal xsane
#pdf manipulation:
$INS texlive-extra-utils texlive-latex-recommended pdftk

# x tools
$INS xbindkeys xvkbd xdotool gkrellm gkrellm-cpufreq

#doc reader
$INS gv fbreader djview4 xchm

#mulit-MEDIA&sound
$INS vlc mplayer smplayer ffmpeg handbrake moc xine-ui rhythmbox audacity pasystray pavucontrol guvcview cheese mediainfo soundconverter

# graphics
$INS gimp inkscape dia

#torrents & p2p
$INS transmission 

#converters
$INS python-plastex pandoc antiword unoconv writer2latex

$INS aspell-ru myspell-ru mythes-ru

#misc
$INS fortune-mod fortunes fortunes-ru
