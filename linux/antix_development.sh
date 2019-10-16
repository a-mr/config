#!/bin/bash

#Essential tools for compiling from sources

$INS build-essential libncurses5-dev gcc libssl-dev bc checkinstall cdbs devscripts dh-make fakeroot libxml-parser-perl check avahi-daemon valgrind 

# misc
$INS m4 libev-dev cputool python-pygments

#x dev
$INS xutils libx11-dev libxkbfile-dev libsecret-1-dev libxext-dev build-essential \
            xautomation xinput xserver-xorg-dev xutils-dev libtool \
            autoconf flex bison autoconf2.13 freeglut3-dev xorg-dev

INSB="apt-get build-dep $1"
#dev for opengl, gtk/gnome
$INSB trackballs extremetuxracer nautilus

# build systems
$INS cmake meson
# other
$INS libgdbm-dev libgsl0-dev libprotobuf-dev protobuf-compiler python-protobuf

