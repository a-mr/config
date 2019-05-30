#!/usr/bin/env bash

SRC="$1"
DST="$2"
copy(){
  echo Copying \""$1"\" to \""$2"\"
  cp -p -r "$1" "$2"
}

service cups stop
for i in "$SRC"/etc/cups/{client.conf,cupsd.conf,printers.conf}; do 
  copy "$i" "$DST/etc/cups/"
done
copy "$SRC"/etc/printcap "$DST/etc/"
service cups start

copy "$SRC"/etc/sysconfig/iptables "$DST"/etc/sysconfig/iptables
service iptables restart

