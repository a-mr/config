#!/bin/bash

echo "unpack-cd.sh : unpacks all .tgz files" 

usage() {
    echo "usage : unpack-cd.sh <directory> <option>"
    echo "option can be '' or -preserve - create directory x/ for x.tar.gz"
}

if [[ "$1" == "" ]]; then
    usage
    exit 10
fi

if [[ "$2" == "" ]]; then
    PRESERVE=false
elif [[ "$2" == "-preserve" ]]; then
    PRESERVE=true
else
    usage
    echo "unknown 2nd option"
    exit 11
fi

cd "$1"

for i in *.tgz; do
    CMD="tar zxvf"
    if [[ "$PRESERVE" == "true" ]]; then
	DIR=`basename "$i" .tgz`
	if [ -d "$DIR" ]; then
	    if [ "$(ls -A $DIR)" ]; then
		echo removing non-empty directory "$DIR" \!
		#continue if not deleted
		rm -I -r "$DIR" && continue
	    else
		rm -r "$DIR"
	    fi
        fi 
	mkdir -p "$DIR"
	$CMD "$i" -C "$DIR"
    else
	$CMD "$i"
    fi
done



