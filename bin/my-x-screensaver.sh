#!/usr/bin/env bash

SWITCH_TIMEOUT=600  # turn the screen off in 10 minutes
BASE_TIMEOUT=$((SWITCH_TIMEOUT/2))

while true; do
    t=`xprintidle`
    t=$((t/1000))
    #echo $t
    if [ $t -gt $SWITCH_TIMEOUT ]; then
        if [ -d ~/nfs ]; then  # home computer
            xset dpms force off
        else                   # work computer
            # light-locker-command -l
            xflock4
        fi
    fi
    sleep $BASE_TIMEOUT
done
