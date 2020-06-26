#!/usr/bin/env bash

# Extended packages: X11 mainly and exotic user-space console tools
. $HOME/.functions.sh

INS="red_command sudo apt-get install -y $1"

$INS xfce4 xfce4-appfinder xfce4-battery-plugin xfce4-clipman-plugin xfce4-cpufreq-plugin xfce4-cpugraph-plugin xfce4-diskperf-plugin xfce4-fsguard-plugin xfce4-genmon-plugin xfce4-mailwatch-plugin xfce4-mount-plugin xfce4-panel xfce4-screenshooter xfce4-sensors-plugin xfce4-smartbookmark-plugin xfce4-systemload-plugin xfce4-terminal xfce4-verve-plugin xfce4-wavelan-plugin xfce4-weather-plugin thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman gvfs gvfs-backends lightdm lightdm-gtk-greeter policykit-1 xfce4-power-manager-plugins xfce4-whiskermenu-plugin xfce4-xkb-plugin xfwm4-themes

#xpra, with all bells and whistles
$INS python-pyinotify python-gtkglext1
$INS --install-suggests xpra

# use eom (eye of mate) as image viewer
$INS chromium spacefm

#clipboard manager
$INS parcellite

$INS julia lua5.1 lua5.3 luajit

$INS jupyter-notebook
$INS sdcv goldendict

#bluetooth headset
$INS pulseaudio pulseaudio-module-bluetooth pavucontrol bluez-firmware blueman

# messaging
$INS pidgin pidgin-sipe pidgin-skype pidgin-latex

