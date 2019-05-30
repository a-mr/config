#!/usr/bin/env bash
find "$@" -type f -printf "%s\n" | sort -n | uniq -d |
    xargs -I@@ -n1 find -type f -size @@c -exec md5sum {} \; |
    sort --key=1,32 | uniq -w 32 -d --all-repeated=separate
