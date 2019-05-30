#!/usr/bin/env bash

. ~/.functions.sh

EXDR="`myextdrive`"

echo terminating skype
killall -u $USER skype

sync.sh out

fumount
if [ $? -ne 0 ]; then
    exit 1
fi

if [ -d "$EXDR/MAKAROV" ]; then
    umount "$EXDR/MAKAROV"
    if [ $? -ne 0 ]; then
	red_echo umount $EXDR/MAKAROV failed. exiting
	exit 1
    fi
fi

if [ -d "$EXDR/WINDOWS" ]; then
    umount "$EXDR/WINDOWS"
    if [ $? -ne 0 ]; then
	red_echo umount /media/WINDOWS failed. exiting
	exit 1
    fi
fi

green_echo Umount succeed:
echo
df
echo
bold_echo Take your usb flash stick now.

function stopwm {
    i3-msg exit
    killall -u $USER dwm
}

mydialog -warning "stop wm?[y|n]" "y stopwm" "n bold_echo OK"

