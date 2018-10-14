#!/bin/bash

CMD=
if [[ "$1" == "" ]]; then
    CMD="mv -v"
elif [[ "$1" == "-git" ]]; then
    CMD="git mv"
elif [[ "$1" == "-hg" ]]; then
    CMD="hg mv"
else
    echo unknown option: "$1"
fi
echo this script renames all file name spaces to underscores in current directory
echo "usage: space.sh [ | -git | -hg ]"

ls | while read -r FILE
do
    echo "$CMD "$FILE" `echo $FILE | tr ' ' '_' `"
    $CMD "$FILE" `echo $FILE | tr ' ' '_' `
done
