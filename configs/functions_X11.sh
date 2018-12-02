
function day () {
 printf '\033]11;white\007'
 printf '\033]10;black\007'
}

function night () {
 printf '\033]11;black\007'
 printf '\033]10;white\007'
}

function xrandr-ls() {
echo `xrandr|grep " connected "|cut -f 1 -d' '`
}

#turn on and mirror all outputs with the same orientation
function xorientation() {
if [[ "$1" == "" ]]; then
local ans=`xrandr|grep " connected "|cut -f 4 -d' '|head -n1`
if [[ "$ans" == "(normal" ]]; then
echo normal
else
echo $ans
fi
else
local outputs="`xrandr-ls`"
#--auto means "turn on with default mode"
for i in `echo $outputs`; do
xrandr --output $i --auto --rotate $1
done
fi
}

function xno {
xorientation normal
}
function xle {
xorientation left
}
function xri {
xorientation right
}

#usage mod_unlock 0x1 to unlock Shift, mod_unlock 0x2 to unlock Caps lock
# KEYMASK	{ Shift, Lock, Control, Mod1, Mod2, Mod3, Mod4, Mod5 } 
function mod_unlock {
  python -c "from ctypes import *; X11 = cdll.LoadLibrary('libX11.so.6'); display = X11.XOpenDisplay(None); X11.XkbLockModifiers(display, c_uint(0x0100), c_uint($1), c_uint(0)); X11.XCloseDisplay(display)"
}

function mysetxkb {
# Enable zapping (C-A-<Bksp> kills X)
setxkbmap -option terminate:ctrl_alt_bksp
#setxkbmap -layout "us,ru" -option "grp:caps_toggle,grp_led:caps,compose:ralt"
local dvorus_dir=~/activity-public/dvorus-layout
#setxkbmap -layout "dvorus_en,dvorus_ru" -print|xkbcomp -w 0 -I$dvorus_dir - $DISPLAY
#setxkbmap -layout "klava_en,klava_ru" -print|xkbcomp -I$dvorus_dir - $DISPLAY
#xmodmap $dvorus_dir/xmodmap
echo load dvorus_evdev
xkbcomp $dvorus_dir/dvorus_evdev.xkb $DISPLAY
echo my > ~/tmp/layout
}

function hissetxkb {
setxkbmap -option terminate:ctrl_alt_bksp
setxkbmap -layout "us,ru" -option "grp:alt_shift_toggle,grp_led:caps,compose:ralt"
echo qwerty > ~/tmp/layout
}

#turn off and then turn on outputs (ignoring 1st) with default orientation
function xon() {
local outputs="`xrandr-ls`"
local output1
local others
local orient=`xorientation`
split1 "$outputs" output1 others
#--auto means "turn on with default mode"
for i in `echo $others`; do
xrandr --output $i --off
xrandr --output $i --auto --right-of $output1 --rotate $orient
done
}

#turn off all outputs except 1st
function xof() {
local outputs="`xrandr-ls`"
local output1
local others
split1 "$outputs" output1 others
for i in `echo $others`; do
    xrandr --output $i --off
done
}

function mydmenu {
dmenu -fn '-xos4-terminus-*-*-*-*-16-*-*-*-*-*-*-*' -l 50 $@
}

# 1st parameter is command to use on file, 2nd is directory
function dmenu_dir {
if [ ! -d $2 ]; then xmessage "directory $2 not found"; return 1; fi
local answer="`ls $2|mydmenu`"
if [ "$answer" != "" ]; then
$1 "$2/$answer"
fi
}

