#!/usr/bin/env bash

#Essential tools for compiling from sources

. $HOME/.functions.sh

INS="red_command sudo apt-get install -y $1"

# for add-apt-repository
$INS software-properties-common

curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"

sudo add-apt-repository "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian buster contrib"
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -

sudo apt update
$INS code virtualbox-6.0 dmg2img

$INS build-essential libncurses5-dev gcc gdb libssl-dev bc cdbs devscripts dh-make fakeroot libxml-parser-perl check avahi-daemon valgrind graphviz libgraphviz-dev

# for xilinx vivado
$INS libtinfo-dev libncursesw5-dev libncurses5 libtinfo5

# misc
$INS m4 libev-dev cputool rlwrap python-pygments rst2pdf meld manpages-dev speedcrunch parallel pdfjam time

#x dev
$INS xutils libx11-dev libxkbfile-dev libsecret-1-dev libxext-dev build-essential \
            xautomation xinput xserver-xorg-dev xutils-dev libtool \
            autoconf flex bison autoconf2.13 freeglut3-dev xorg-dev

INSB="red_command sudo apt-get build-dep -y $1"
#dev for opengl, gtk/gnome
$INSB trackballs extremetuxracer nautilus

# build systems
$INS cmake meson
# other
$INS libgdbm-dev libgsl0-dev libprotobuf-dev protobuf-compiler python-protobuf

#nim:
$INS lmodern nodejs
