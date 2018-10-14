#!/bin/bash

for i in $2; do
	echo -- migrating to $i
        HASH=`cat /etc/shadow|grep $1|cut -d: -f2`
	NEWUID=`cat /etc/passwd|grep $1|cut -d: -f3`
	ssh $i "useradd -u $NEWUID $1; usermod -p '$HASH' $1"
done
