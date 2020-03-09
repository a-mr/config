#!/usr/bin/env bash

#Essential tools for compiling from sources

. $HOME/.functions.sh

INS="red_command sudo apt-get install -y $1"

$INS build-essential libncurses5-dev gcc libssl-dev bc cdbs devscripts dh-make fakeroot libxml-parser-perl check avahi-daemon valgrind 

# misc
$INS m4 libev-dev cputool python-pygments manpages-dev

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

