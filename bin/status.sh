#!/usr/bin/env bash

( while true; do weather.sh > ~/tmp/weather; sleep 1200; done ) &

sleep 1

while true; do
    sep="   "
    echo -ne "$sep"
    echo -ne `cat ~/tmp/weather`
    echo -ne "$sep"
    echo -ne `date +'%b%d %a %H:%M'`
    echo -ne "$sep"
    echo -ne `upower -i /org/freedesktop/UPower/devices/battery_BAT0|grep percentage | awk {'print $2'}` 
    echo
    sleep 1
done

rm ~/tmp/weather
