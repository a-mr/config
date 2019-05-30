#!/usr/bin/env bash

. ~/.functions.sh
base="`basename $1 .djvu`"

echo convert to pdf
djvu2pdf.sh "$base.djvu" "$base.aux.pdf"
echo split pdf
un2up-pdf.py <"$base.aux.pdf" >"$base.aux2.pdf"
mydialog "inspect pdf file?[y|n]" "y xdg-open \"$base.aux2.pdf\"" "n echo OK"
echo convert back to djvu
pdf2djvu.sh "$base.aux2.pdf"
mv "$base.djvu" "$base-old.djvu"
mv "$base.aux2.djvu" "$base.djvu"
rm -f "$base.aux.pdf" "$base.aux2.pdf"

