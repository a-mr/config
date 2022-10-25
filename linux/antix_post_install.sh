#!/usr/bin/env bash

for group in vboxsf vboxusers dialout docker; do
    sudo usermod -a -G $group $USER
done

echo $'Section "ServerFlags"\n  Option "DontZap" "yes"\nEndSection' \
    | sudo tee /usr/share/X11/xorg.conf.d/dontzap.conf
