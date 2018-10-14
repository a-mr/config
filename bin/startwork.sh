#!/bin/bash

. ~/.bashrc

mydialog "Start skype? [yn]" "y echo starting skype...; skype&" "n echo hide..."

EXDR="`myextdrive`"

while true; do
    mnt MAKAROV WINDOWS
    if [ -d "$EXDR/MAKAROV" ]; then
	echo "$EXDR/MAKAROV" was found, continueing...
	break
    fi
    echo not found "$EXDR/MAKAROV", waiting 30 seconds...
    sleep 30
done

if [ -d "$EXDR/MAKAROV" ]; then
    echo starting Thunderbird
    thunderbird &
    echo starting work diary
    wd &
else
    red_echo "You did not insert your usb flash stick. Exiting."
    exit 1
fi

sync.sh in

#bold_echo "Adding ssh key by ssh-add."
#if exist /usr/bin/ssh-askpass; then 
#    /usr/bin/ssh-askpass&
#elif exist /usr/lib/ssh/x11-ssh-askpass; then
#    /usr/lib/ssh/x11-ssh-askpass
#else
#    ssh-add
#fi
#

default_shell

