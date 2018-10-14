#!/bin/bash

( while true; do weather.sh > ~/tmp/weather; sleep 600; done ) &

sleep 1

echo '{"version":1} ['
while true; do
    line="["
    #line="$line { \"full_text\" : \"`xkblayout-state print "%n"`\" }"
    #line="$line, "
    line="$line { \"full_text\" : \"battery `upower -i /org/freedesktop/UPower/devices/battery_BAT0|grep percentage | awk {'print $2'}`\" }"
    line="$line, { \"full_text\" : \"Погода `cat ~/tmp/weather`\" }"
    line="$line, { \"full_text\" : \"`date +'%m.%d %a %H:%M'`\" }"
    line="$line ],"
    echo $line
    echo
    sleep 1
done

rm ~/tmp/weather
