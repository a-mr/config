#!/usr/bin/env bash

xdg-mime default evince.desktop application/pdf
xdg-mime default evince.desktop application/ps

xdg-mime default nautilus.desktop inode/directory

cat /usr/share/applications/nautilus.desktop|sed -e "s|Exec=nautilus|Exec=$HOME/bin/wrappers/nautilus|g" > ~/.local/share/applications/nautilus.desktop

