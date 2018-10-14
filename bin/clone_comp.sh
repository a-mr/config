#!/bin/bash

DIR=$2
if [ "$1" == "to" ]; then

mkdir -p $DIR 
mkdir -p $DIR/ssh 
mkdir -p $DIR/cups

#cp /etc/ssh/ssh{d_config,_config,_host_dsa_key,_host_dsa_key.pub,_host_key,_host_key.pub,_host_rsa_key,_host_rsa_key.pub} $DIR/ssh
cp /etc/ssh/ssh{d_config,_config,_host*key*} $DIR/ssh

cp /etc/{passwd,shadow,group} $DIR
cp /etc/cups/{client.conf,cupsd.conf} $DIR/cups
cp /etc/fstab $DIR
cp /root/.bash_history $DIR/bash_history

cp /etc/sysconfig/network-scripts/ifcfg-Auto* $DIR
mkdir -p $DIR/NetworkManager
cp /etc/NetworkManager/system-connections/* $DIR/NetworkManager

elif [ "$1"=="from" ]; then
	cp $DIR/{passwd,shadow,group} /etc
	cp $DIR/ssh/* /etc/ssh
	cat $DIR/bash_history >> /root/.bash_history
        cp $DIR/cups/* /etc/cups
	echo not copying fstab
else
echo usage
exit 1
fi
