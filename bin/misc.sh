#!/usr/bin/env bash


case "$1" in
    "ps2pdf")
	for i in `find . -name "*.ps"`; do 
	    dn="`dirname $i`"; 
	    bn="`basename $i .ps`"; pdf="$dn/$bn.pdf"; 
	    if [ -f "$pdf" ]; then 
		ls $pdf; 
	    else 
		ps2pdf -sPAPERSIZE=a4 -dOptimize=true -dEmbedAllFonts=true $i $pdf; 
	    fi; 
	done;
	;;
    "uppercase")
        while read i; do 
            echo $i | perl -CS -ne 'print uc' | xclip -selection c; 
        done
        ;;
    
	*)
	echo unrecognized option "$1"
	;;
esac
