#!/bin/bash

INS="emerge -u"

$INS mc gkrellm zsh tcsh screen tmux lm_sensors sshpass xclip rxvt-unicode
$INS iftop ethtool traceroute
#misc
$INS rlwrap wmname xdelta
$INS texlive 
$INS psutils xournal xsane 
$INS sdcv
#
##internet
$INS firefox thunderbird elinks wvdial
##Version control:
$INS cvs subversion mercurial tortoisehg bzr git darcs 

## fortran
$INS gfortran cernlib paw
#
##Java runtime environment
$INS icedtea-bin
#
##editors/IDE
layman -a java
$INS app-editors/emacs haskell-mode dev-util/eclipse-sdk-bin
## graphics
$INS gimp inkscape
#
$INS skype # ekiga
#

# tricks

#for vmware
USE="-icu" emerge -1O dev-libs/libxml2
