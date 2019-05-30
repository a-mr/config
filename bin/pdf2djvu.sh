#!/usr/bin/env bash

. ~/.functions.sh
base="`basename $1 .pdf`"
#pdf2djvu -o "$base.djvu" -d 400 "$base.pdf"

function w1 {
gs -SDEVICE=tiffg4 -r300x300 -sOutputFile=./pages_%04d.aux.tif -dNOPAUSE -dBATCH -- "$base.pdf"
didjvu bundle *.tif > "$base.djvu"
rm -f pages_????.aux.tif
}

function w2 {
gs -SDEVICE=tiffg4 -r300x300 -sOutputFile=./pages_%04d.aux.tif -dNOPAUSE -dBATCH -- "$base.pdf"
djvubind --no-ocr
mv book.djvu "$base.djvu"
rm -f pages_????.aux.tif
}

function w3 {
any2djvu "$base.pdf"
}

function w4 {
pdf2djvu -o "$base.djvu" -d 300 "$base.pdf"
}

mydialog "utility to use? [1 - didjvu (rather good); 2 - djvubind (monochrome(?), rather good, can be very memory-consuming); 3 - any2djvu (good, BUT: external server\!\!\!); 4 - pdf2djvu (relatively bad, but preserves OCR)" "1 w1" "2 w2" "3 w3" "4 w4"

CMD="ocrodjvu -e tesseract --in-place \"$base.djvu\""
mydialog "do OCR recognition? [no|eng|rus]" "no warning_echo no OCR" "eng $CMD -l eng" "rus $CMD -l rus"

