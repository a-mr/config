#!/usr/bin/env bash

# $! - file name $2 - shrink factor

N_LINES=`cat $1|wc -l`
M_LINES=$(($N_LINES/$2))

sort -R "$1" | head -n $M_LINES

