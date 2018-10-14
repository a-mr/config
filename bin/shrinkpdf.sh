#!/bin/bash

. ~/.functions.sh

out=out.pdf
if [[ "$2" != "" ]] ; then
    out="$2"
fi
DPI=$(myread "DPI=? " 300)

echo output to $out
gs \
  -o "$out" \
  -sDEVICE=pdfwrite \
  -dDownsampleColorImages=true \
  -dDownsampleGrayImages=true \
  -dDownsampleMonoImages=true \
  -dColorImageResolution=$DPI \
  -dGrayImageResolution=$DPI \
  -dMonoImageResolution=$DPI \
   $1

#  -dColorImageResolution=72 \
#  -dGrayImageResolution=72 \
#  -dMonoImageResolution=72 \
#gs	-q -dNOPAUSE -dBATCH -dSAFER \
#	-sDEVICE=pdfwrite \
#	-dCompatibilityLevel=1.3 \
#	-dPDFSETTINGS=/screen \
#	-dEmbedAllFonts=true \
#	-dSubsetFonts=true \
#	-dColorImageDownsampleType=/Bicubic \
#	-dColorImageResolution=72 \
#	-dGrayImageDownsampleType=/Bicubic \
#	-dGrayImageResolution=72 \
#	-dMonoImageDownsampleType=/Bicubic \
#	-dMonoImageResolution=72 \
#	-sOutputFile=out.pdf \
#	 $1
