#!/usr/bin/env bash

make-googleearth-package --force
dpkg -i googleearth*.deb
