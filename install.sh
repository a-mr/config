#!/bin/bash

CTPATH="$HOME/activity-public/computer-program-data"

. $CTPATH/configs/functions.sh

cd $CTPATH
chmod g-w -R configs

BLOC=$CTPATH/bin
DDIR="$HOME"

# 'inst' makes link from $1 to ~/.$1 or $2
# If $2 is given, full path should be specified.

LNK="ln -sfT"
inst(){
	SRC="`$BLOC/fullpath $1`"
	DSTC=
	if [ "$2" == "" ]; then
		DSTC="$DDIR/.$1"
	else
		DSTC="$2"
	fi
	DST="`$BLOC/fullpath $DSTC`"
	PARENT="`dirname $DST`"
	mkdir -p "$PARENT"
	echo $LNK "$SRC" "$DST"
	$LNK "$SRC" "$DST"
	isok
}

oinst(){
    if [[ "$1" == "-a" ]]; then
        inst $@
    else
        echo skipping $@
    fi
}

echo $LNK $BLOC ~/bin
$LNK $BLOC ~/bin

if [[ -d ~/works-shared ]]; then
    mkdir -p ~/.stardict/dic
    for i in ~/works-shared/dic/* ; do
	echo $LNK \"$i\" ~/.stardict/dic/`basename "$i"`
        $LNK "$i" ~/.stardict/dic/`basename "$i"`
    done
fi

cd configs

inst face.png ~/.face
#inst purple ~/.purple
inst shellprofile.sh ~/.bash_profile
inst shellprofile.sh ~/.zprofile
inst shellrc.sh ~/.bashrc
inst shellrc.sh ~/.zshrc

oinst roxterm.sourceforge.net ~/.config/roxterm.sourceforge.net
oinst lxpanel-default ~/.config/lxpanel/default
inst easystroke ~/.easystroke
inst autostart ~/.config/autostart
inst mimeapps.list ~/.config/mimeapps.list

inst gtk-3.0-settings.ini ~/.config/gtk-3.0/settings.ini
#for gnome
inst user-dirs.conf ~/.config/user-dirs.conf

cp evince-accels ~/.config/evince/accels

inst vscode-User ~/.config/Code/User
oinst myzenburn.vimp ~/.vimperator/colors/myzenburn.vimp
oinst $CTPATH/vim/zenburn.penta/zenburn.penta ~/.pentadactyl/colors/zenburn.penta

mkdir -p ~/tmp/VIM_TMP
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
    oinst $CTPATH/vim/vim-pathogen/autoload/pathogen.vim ~/.vim/autoload/pathogen.vim 
oinst $CTPATH/vim/vim-easymotion ~/.vim/bundle/vim-easymotion
#red_command vim-addons install latex-suite
oinst xmonad.hs ~/.xmonad/xmonad.hs
aux_echo xmonad recompile
xmonad --recompile

for i in functions.sh functions_X11.sh emacs vimrc gdbinit gdbinit.local \
    hgrc hgstyle gitconfig xsession tmux.conf screenrc Xresources inputrc \
    xinputrc; do
    inst $i
done
for i in i3 textadept pentadactylrc vimperatorrc keynavrc conkyrc xxkbrc \
    xbindkeysrc ocamlinit ghci rootlogon.C juliarc.jl psqlrc; do
	oinst $i
done

mkdir -p ~/.config/xfce4
for i in xfce4/*; do
	inst $i ~/.config/$i
done

oinst xpra.conf ~/.xpra/xpra.conf

oinst awesome-rc.lua ~/.config/awesome/rc.lua
#if [ "`os_distribution`" = "ubuntu" ]; then
#    echo "install thunderbird profiles for ubuntu"
#    inst profiles_for_ubuntu.ini ~/.thunderbird/profiles.ini
#elif [ "`os_distribution`" = "arch" ]; then
#    aux_echo "install thunderbird profiles for debian"
#    inst profiles_for_arch.ini ~/.thunderbird/profiles.ini
#elif [ "`os_distribution`" = "debian" ]; then
#    aux_echo "install thunderbird profiles for debian"
#    inst profiles_for_ubuntu.ini ~/.icedove/profiles.ini
#else
#    inst profiles.ini ~/.thunderbird/profiles.ini
#fi


if [[ "$1" == "-a" ]]; then
    dconf load /org/gnome/terminal/ < org.gnome.terminal
    dconf load /desktop/ibus/ < desktop.ibus

    $CTPATH/configs/set-xdg-mime.sh

    #mkdir -p ~/.ssh
    #cp $CTPATH/configs/ssh_config ~/.ssh/config
    #chmod 600 ~/.ssh/config

    if [[ -d /usr/share/texlive/texmf-dist/fonts/truetype/paratype/ ]]; then
        mkdir -p ~/.fonts
        ln -sfT /usr/share/texlive/texmf-dist/fonts/truetype/paratype/ ~/.fonts/paratype
        fc-cache -fv
    fi
fi
