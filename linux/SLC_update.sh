#!/usr/bin/env bash

# For Scientific (RHEL, CentOS) Linux 6

INS="yum install -y" 
GET=wget
GRINS="yum groupinstall -y"

# work around dependency problem
yum remove -y libvpx-0.9.0-8.el6_0 mplayer-common xine-lib ocaml
rpm -ihv ftp://fr2.rpmfind.net/linux/atrpms/sl6-x86_64/atrpms/testing/libvpx-1.0.0-1.el6.`uname -m`.rpm
$INS mplayer smplayer

# in case of mismatch between Xorg & drivers ABI:
# yum downgrade xorg-x11-server-Xorg

yum update -y 

