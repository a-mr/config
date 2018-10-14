#!/bin/bash

base="`basename $1 .djvu`"

djvu_file=$1
pn=$(djvudump "$djvu_file"| grep "Document directory"|awk '{for(o=1;o<=NF;o++) if ($o =="pages)" ) {print $(o-1)} }')
pushd . > /dev/null
tmp=$(mktemp -d -t djvu_ocr_pdf.XXX)
echo $tmp
cp "$djvu_file" $tmp/tmp.djvu
cd $tmp
for i in `seq 1 $pn` ; do
    ii=$(printf "%010d" $i)
    { djvu2hocr -p ${ii} tmp.djvu || break ; } | sed 's/ocrx/ocr/g' > tmp_${ii}.html
    ddjvu -format=tiff -page=${ii} tmp.djvu tmp_${ii}.tif
done
pdfbeads -o tmp.pdf
popd > /dev/null
cp $tmp/tmp.pdf ${djvu_file%.djvu}.pdf
rm -rf $tmp

