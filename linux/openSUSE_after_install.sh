#!/usr/bin/env bash

# For openSUSE 13.1

#enable files caching
zypper modifyrepo -k --all

INS="zypper --non-interactive install" 
INSG="zypper --non-interactive install -t pattern"
INSGI="zypper install -t pattern"
GET=wget

zypper --non-interactive update --auto-agree-with-licenses

################################################
# Basic installation
################################################
$INSG xfce
zypper --non-interactive rm patterns-openSUSE-kde4_pure
$INSG gnome
$INSG devel_C_C++
$INSG devel_qt4 devel_python devel_tcl devel_gnome
#texlive & others
$INSG technical_writing

$INS xterm rxvt-unicode mc gkrellm conky bash-completion tmux sensors xclip iftop nmap socat
#misc tools
$INS python-pygments rlwrap dmenu kdiff3 xdelta smartmontools telnet luvcview xawtv ibus ibus-table-latex glipper parcellite #clipboard manager

#latex
$INS emacs-auctex

$INS gcc-fortran

$INS cvs subversion bzr git unison mercurial


