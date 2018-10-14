#!/bin/bash

groupadd -g 505 hg
useradd -s /sbin/nologin -r -M -u 505 -g 505 hg
users=`cat /etc/passwd|awk -F':' '{ if ($3 >= 500 && $3 <= 65000) print $1}'`
for i in $users; do
    CMD="usermod -a -G hg $i"
    echo $CMD
    $CMD
done

