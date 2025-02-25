#!/usr/bin/env bash

#Essential tools for compiling from sources

. $HOME/.functions.sh

INS="red_command sudo apt-get install -y $1"

#Version control:
$INS cvs subversion mercurial tortoisehg bzr git git-lfs gitk gitweb git-email libemail-valid-perl libmailtools-perl libauthen-sasl-perl darcs

wget https://github.com/dandavison/delta/releases/download/0.18.2/git-delta_0.18.2_amd64.deb
dpkg -i git-delta_0.18.2_amd64.deb
rm git-delta_0.18.2_amd64.deb

# misc
$INS m4 libev-dev cputool rlwrap python3-pygments python3-venv rst2pdf meld manpages-dev speedcrunch parallel time
# $INS linux-tools-generic linux-tools-common # for perf
# ubuntu: pdfjam in texlive-extra-utils

#x dev
$INS xutils libx11-dev libxkbfile-dev libsecret-1-dev libxext-dev build-essential \
            xautomation xinput xserver-xorg-dev xutils-dev libtool \
            autoconf flex bison autoconf2.13 freeglut3-dev xorg-dev \
            libglfw3-dev libglew-dev # for Nuklear

INSB="red_command sudo apt-get build-dep -y $1"
#dev for opengl, gtk/gnome
$INSB trackballs extremetuxracer nautilus

# build systems
$INS cmake meson
# other
$INS libgdbm-dev libgsl0-dev libprotobuf-dev protobuf-compiler python3-protobuf python3-fonttools

#nim:
$INS lmodern nodejs npm

# for add-apt-repository
$INS software-properties-common

curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt update
$INS code

# Ubuntu has its own virtualbox:
#sudo add-apt-repository "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian buster contrib"
#wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -

#$INS virtualbox-6.1 dmg2img  # debian
$INS virtualbox dmg2img  # ubuntu

$INS build-essential libncurses5-dev gcc clangd gdb libssl-dev bc cdbs devscripts dh-make fakeroot libxml-parser-perl check avahi-daemon valgrind graphviz libgraphviz-dev
# script that should install all development packages of installed packages:
~/bin/install-all-dev-packages.sh

# for debugging any C program in gdb, etc
cd /usr/src
red_command sudo apt source glibc
cd -

# for xilinx vivado
$INS libtinfo-dev libncursesw5-dev libncurses5 libtinfo5

# ARM:
$INS device-tree-compiler qemu-user-static debootstrap gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf libc-dev-arm64-cross libc-dev-armhf-cross

# doc & man pages:
$INS manpages-posix-dev gcc-doc zeal

# docker

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
$INS docker-ce docker-ce-cli containerd.io docker-compose-plugin
