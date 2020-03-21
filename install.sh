#!/usr/bin/env bash

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

os=`uname`
LNK () {
  if [[ $os == Linux ]]; then
	echo ln -sfT $@
	  ln -sfT "$1" "$2"
  else
	echo ln -sf $@
	  ln -sf "$1" "$2"
  fi
}

inst () {
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
	LNK "$SRC" "$DST"
	isok
}

oinst () {
    if [[ "$option" == "-a" || "$option" == "-all" ]]; then
        inst $@
    else
        echo skipping $@
    fi
}

LNK $BLOC ~/bin

cd configs

inst face.png ~/.face
#inst purple ~/.purple
inst shellprofile.sh ~/.bash_profile
inst shellprofile.sh ~/.zprofile
inst shellrc.sh ~/.bashrc
inst shellrc.sh ~/.zshrc

inst konsole/konsolerc ~/.config/konsolerc
inst konsole/konsoleui.rc ~/.local/share/kxmlgui5/konsole/konsoleui.rc
inst konsole/sessionui.rc ~/.local/share/kxmlgui5/konsole/sessionui.rc
inst "konsole/Profile 5.profile" "$HOME/.local/share/konsole/Profile 5.profile"

oinst roxterm.sourceforge.net ~/.config/roxterm.sourceforge.net
oinst lxpanel-default ~/.config/lxpanel/default
inst easystroke ~/.easystroke
inst fonts.conf
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
inst $CTPATH/vim/vim-easymotion ~/.vim/bundle/vim-easymotion
#red_command vim-addons install latex-suite
oinst xmonad.hs ~/.xmonad/xmonad.hs
aux_echo xmonad recompile
xmonad --recompile

for i in functions.sh functions_advanced.sh functions_X11.sh \
    emacs vimrc gdbinit gdbinit.local \
    hgrc hgstyle gitconfig xsession xsessionrc \
    tmux.conf screenrc Xresources inputrc \
    xinputrc; do
    inst $i
done

inst gitk ~/.config/git/gitk
inst parcelliterc ~/.config/parcellite/parcelliterc
inst vifmrc ~/.vifm/vifmrc

for i in icewm i3 i3status.conf gkrellm2 \
    textadept pentadactylrc vimperatorrc keynavrc xxkbrc \
    xbindkeysrc ocamlinit ghci rootlogon.C juliarc.jl psqlrc; do
	oinst $i
done
ln -s /usr/share/desktop-menu/.icewm/menu-applications ~/.icewm/menu-applications

mkdir -p ~/.config/xfce4
for i in xfce4/*; do
	inst $i ~/.config/$i
done

oinst xpra.conf ~/.xpra/xpra.conf

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
