#!/bin/bash

# -a archive mode
# -z compressing
# -u skip files that a newer -
# -v verbose
# -H preserve hard links

rsync -azvHu -e ssh "$1" "$2/$1"

