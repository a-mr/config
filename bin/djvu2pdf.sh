#!/bin/bash
base="`basename $1 .djvu`"
out="$base.pdf"
if [ "$2" != "" ]; then
    out="$2"
fi
ddjvu -format=pdf "$base.djvu" "$out"
