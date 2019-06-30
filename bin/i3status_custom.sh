#!/bin/bash

# sum frequencies of all cores
calc_freq () {
  while read -r line
  do
      (( n++ ))
      (( sum = sum + line ))
  done < <(cat /proc/cpuinfo | grep "cpu MHz" | cut -d: -f2 \
           | cut -d. -f1 ) # bash can not support floating point
  (( sum = sum / n ))
  printf "%04d MHz" $sum
}

i3status | while :
do
        read line
        echo "$line | `calc_freq` | ww`date +%V`" || exit 1
done

