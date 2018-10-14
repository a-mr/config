#!/bin/bash

# -a archive mode
# -z compressing
# -u skip files that a newer -
# -v verbose
# -H preserve hard links

rsync -azvH -e ssh $@

