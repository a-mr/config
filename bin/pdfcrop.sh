#!/bin/sh

mydir=$(mktemp -dt "`basename $0`.XXXXXXXXXX")

echo run pdfcrop in $mydir
echo pdfcrop --margins "5 5 5 5" "$1" $mydir/1.pdf
pdfcrop --margins "5 5 5 5" "$1" $mydir/1.pdf

echo run pdf2ps
pdf2ps $mydir/1.pdf $mydir/2.ps

echo run ps2pdf
ps2pdf $mydir/2.ps $mydir/3.pdf

if [ "$2" != "" ]; then
    mv $mydir/3.pdf "$2"
else
    mv $mydir/3.pdf `dirname $1`/`basename $1 .pdf`-cropped.pdf
fi
rm -rf $mydir


