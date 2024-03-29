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

inst qterminal.org ~/.config/qterminal.org
inst qpdfview ~/.config/qpdfview
inst konsole/konsolerc ~/.config/konsolerc
inst konsole/konsoleui.rc ~/.local/share/kxmlgui5/konsole/konsoleui.rc
inst konsole/sessionui.rc ~/.local/share/kxmlgui5/konsole/sessionui.rc
inst "konsole/Profile 5.profile" "$HOME/.local/share/konsole/Profile 5.profile"
inst Linux.colorscheme ~/.local/share/konsole/Linux.colorscheme

oinst roxterm.sourceforge.net ~/.config/roxterm.sourceforge.net
oinst lxpanel-default ~/.config/lxpanel/default
inst easystroke ~/.easystroke
inst fonts.conf
inst autostart ~/.config/autostart
inst recoll.conf ~/.recoll/recoll.conf
inst recoll.ini ~/.config/Recoll.org/recoll.ini
ln -f mimeapps.list ~/.local/share/applications/mimeapps.list  # older Linuxes
ln -f mimeapps.list ~/.config/mimeapps.list
ln -f defaults.list ~/.local/share/applications/defaults.list

inst xsessionrc ~/.xsessionrc-x2go
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

# vim does not consider directory `ftdetect` if it's not in ~/.vim
mkdir -p ~/.vim/ftdetect
inst $CTPATH/vim/ultisnips/ftdetect/snippets.vim ~/.vim/ftdetect/snippets.vim
inst $CTPATH/vim/nim.vim/ftdetect/nim.vim ~/.vim/ftdetect/nim.vim

#red_command vim-addons install latex-suite
oinst xmonad.hs ~/.xmonad/xmonad.hs
aux_echo xmonad recompile
xmonad --recompile

for i in functions.sh functions_advanced.sh functions_X11.sh functions_vcs.sh \
    emacs vimrc gdbinit gdbinit.local \
    hgrc hgstyle gitconfig xsession xsessionrc \
    tmux.conf screenrc Xresources inputrc \
    xinputrc less; do
    inst $i
done

inst gitk ~/.config/git/gitk
inst parcellite ~/.config/parcellite
inst ranger-rc.conf ~/.config/ranger/rc.conf
inst ranger-rifle.conf ~/.config/ranger/rifle.conf
inst vifmrc ~/.vifm/vifmrc

for i in ideavimrc icewm i3 i3status.conf gkrellm2 \
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
    # for telegram-desktop natural scrolling in Linux in TOUCHPAD (TODO: why is it "mouse")
    gsettings set org.gnome.desktop.peripherals.mouse natural-scroll true
    dconf load /org/gnome/terminal/ < org.gnome.terminal
    dconf load /desktop/ibus/ < desktop.ibus

    #mkdir -p ~/.ssh
    #cp $CTPATH/configs/ssh_config ~/.ssh/config
    #chmod 600 ~/.ssh/config

    if [[ -d /usr/share/texlive/texmf-dist/fonts/truetype/paratype/ ]]; then
        mkdir -p ~/.fonts
        LNK /usr/share/texlive/texmf-dist/fonts/truetype/paratype/ ~/.fonts/paratype
        LNK /usr/share/texlive/texmf-dist/fonts/truetype/ascender/droid/ ~/.fonts/droid
        LNK /usr/share/texlive/texmf-dist/fonts/opentype/public/ebgaramond ~/.fonts/ebgaramond
        fc-cache -fv
    fi
fi
