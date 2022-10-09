#!/usr/bin/env bash

for group in vboxsf vboxusers dialout docker; do
    sudo usermod -a -G $group $USER
done
