#!/bin/bash

# allow sym links for Windows
export MSYS=winsymlinks:nativestrict

option="$1"
CTPATH="$HOME/activity-public/computer-program-data"

. $CTPATH/configs/functions.sh

if [[ "$option" != "" && "$option" != "-a" && "$option" != "-all" ]]; then
    red_echo "unknown option" "$option"
    echo "allowed options: -a -all"
    exit 1
fi

cd $CTPATH
chmod g-w -R configs

BLOC=$CTPATH/bin
DDIR="$HOME"

# 'inst' makes link from $1 to ~/.$1 or $2
# If $2 is given, full path should be specified.

LNK="ln -sfT"
inst(){
	SRC="`$BLOC/fullpath \"$1\"`"
	DSTC=
	if [ "$2" == "" ]; then
		DSTC="$DDIR/.$1"
	else
		DSTC="$2"
	fi
	DST="`$BLOC/fullpath \"$DSTC\"`"
	PARENT="`dirname \"$DST\"`"
	mkdir -p "$PARENT"
	echo $LNK "$SRC" "$DST"
	$LNK "$SRC" "$DST"
	isok
}

oinst(){
    if [[ "$option" == "-a" || "$option" == "-all" ]]; then
        inst $@
    else
        echo skipping $@
    fi
}

echo $LNK $BLOC ~/bin
$LNK $BLOC ~/bin

cd configs

inst Microsoft.PowerShell_profile.ps1 ~/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1
inst shellprofile.sh ~/.bash_profile
inst shellprofile.sh ~/.zprofile
inst shellrc.sh ~/.bashrc
inst shellrc.sh ~/.zshrc

#inst vscode-User "$APPDATA/Code/User"
inst vscode-User "/c/Users/$USERNAME/AppData/Roaming/Code/User"

mkdir -p ~/tmp/VIM_TMP
inst $CTPATH/vim/vim-easymotion ~/.vim/bundle/vim-easymotion

for i in functions.sh functions_X11.sh emacs vimrc gdbinit gdbinit.local \
    hgrc hgstyle gitconfig tmux.conf screenrc Xresources inputrc \
    xinputrc; do
    inst $i
done

for i in textadept ocamlinit ghci rootlogon.C juliarc.jl psqlrc; do
	oinst $i
done

oinst xpra.conf ~/.xpra/xpra.conf

