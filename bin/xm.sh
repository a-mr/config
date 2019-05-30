#!/usr/bin/env bash

. ~/.functions_X11.sh

case $1 in
    "reset") xcalib -clear;;
#    2) xcalib -gc 0.55 -co 40 -a;;
    "lower") xcalib -gc 0.9 -co 70 -a;;
    "invert") xcalib -gc 0.55 -co 40 -invert -a ;;
    "upright") xno;;
    "left") xle;;
    *) xcalib -clear;;
esac

