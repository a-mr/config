
# Contents
# [Init] initialization
# [Secton GUI] functions suitable both for interactive work in graphics(X11) and command line
# [Section CMD] fuctions suitable only for interactive work in command line

################################################################################
# [Init]
################################################################################

###############################################################################
# initial settings
[ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH2_CLIENT" ] \
    && inside_ssh=true
[ -n "$VNCDESKTOP" ] && inside_vnc=true

# Note $SHELL env. variable can be wrong
CURSHELL=`ps -p $$ | tail -1 | awk '{print $NF}'`

function default_shell {
if [[ "$ALLOW_BASH" == "" ]] && which zsh &> /dev/null && \
    [[ "$CURSHELL" != "/bin/zsh" && "$CURSHELL" != "zsh" ]]; then
    echo starting zsh
    exec zsh
    #exec /bin/zsh
fi
}

# If connected to terminal then start default shell
tty -s
if [[ "0" == "$?" && "$ONLYREADCONF" != "y" ]]; then
    default_shell
fi

#don't echo: prevents scp to work!
#echo "reading main config.file..."
# all functions which can be of use in all kinds of scripts are in
# ~/.functions.sh
. ~/.functions.sh

. ~/.functions_X11.sh

# Enforce correct locales from the beginning:
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_MESSAGES=en_US.UTF-8
export LC_NUMERIC=en_US.UTF-8
if locale -a|grep -i en_DK.utf8 > /dev/null; then
# ISO 8601 date format
export LC_TIME=en_DK.UTF-8
else
	export LC_TIME=en_US.UTF-8
fi

################################################################################
# [Section GUI]
################################################################################

export EXDR="`myextdrive`"
# fix latest Debian Chromium disabling remote extensions
export CHROMIUM_FLAGS=$CHROMIUM_FLAGS" --enable-remote-extensions"

# there are only simple alias-like functions for shell convenience here

if exist vimx; then
    export EDITOR=vimx
else
    export EDITOR=vim
fi

if [[ "$SSH_CONNECTION" == "" ]]; then
#	export EDITOR=emacs
	export BROWSER=firefox
else
#	export EDITOR="emacs -nw"
	export BROWSER=links
fi

export VISUAL="$EDITOR"
for term in konsole urxvt gnome-terminal xterm roxterm rxvt-unicode xfce4-terminal ; do
	if exist $term; then
		export XTERMINAL=$term
		break
	fi
done

if [ -f /etc/lsb-release ]; then
	. /etc/lsb-release
	export DISTRIB_ID
	export DISTRIB_RELEASE
fi

# textadept editor
function ta {
textadept $@
}

function tac {
textadept-curses $@
}

#julia
function julianb {
    julia -e "using IJulia; notebook()"
}

#lua
function lr {
luarocks --local $@
}

function lr51 {
luarocks-5.1 --local $@
}

function lr53 {
luarocks-5.3 --local $@
}

function l53 {
eval `luarocks-5.3 path --bin`
lua $@
}

function l51 {
eval `luarocks-5.1 path --bin`
lua5.1 $@
}

function lj {
eval `luarocks-5.1 path --bin`
rlwrap luajit $@
}

# misc.aliases
function wd {
rednotebook $EXDR/MAKAROV/activity-personal/draft_mak/work_diary
}
function pd {
rednotebook $EXDR/MAKAROV/activity-personal/draft_mak/personal_diary
}
function c {
echo $@|bc -l
}

function untar {
# do not try to change times
tar zxvf $@ --no-overwrite-dir
}

function fm {
thunar
}

if exist icedove && ! exist thunderbird; then
    function thunderbird {
    icedove
    }
fi

function android-connect {
mtpfs -o allow_other ~/tmp/note
}
function android-disconnect {
fusermount -u ~/tmp/note
}
function yandex {
mkdir -p $HOME/mnt/yandex.disk
sudo mount -t davfs -o gid=$GID,uid=$UID https://webdav.yandex.ru $HOME/mnt/yandex.disk
}
function uyandex {
sudo umount $HOME/mnt/yandex.disk
}

function use {
	local fuser="/bin/fuser"
	if exist /sbin/fuser; then
		fuser="/sbin/fuser"
	fi
        if [ -d "$1" ]; then
		$fuser -vm $@
        else
                $fuser -v $@
        fi
}

function sync {
unison ~/activity-public/current "`myextdrive`"/MAKAROV/activity-public/current
}

function syn {
bold_echo rsync dry run
# slash "/" after "$1" is essential
rsync -rvCn --size-only "$1/" "$2"
mydialog -warning "Proceed? [y|n]" \
"y rsync -rvC --size-only \"$1/\" \"$2\"" \
"n bold_echo doing nothing"
}

#version with delete
function synd {
bold_echo rsync dry run
# slash "/" after "$1" is essential
rsync -rvCn --delete --size-only "$1/" "$2"
mydialog -warning "Proceed? [y|n]" \
"y rsync -rvC --delete --size-only \"$1/\" \"$2\"" \
"n bold_echo doing nothing"
}

################################################################################
# [Section CMD]
################################################################################

# If not running interactively, don't do anything else
if [[ "$PS1" == "" ]]; then
    return
fi

if [[ "$ONLYREADCONF" == "y" ]]; then
    return
fi

##ensure we are running default shell
#if [[ "$ALLOW_BASH" == "" ]] && exist /bin/zsh && \
#	[[ "$CURSHELL" != "/bin/zsh" && "$CURSHELL" != "zsh" ]]; then
#    echo Found zsh. Launch it "($@)".
#    exec /bin/zsh $@
##if [[ ( "$SHLVL" == "1" || "$SHLVL" == "2" ) && "$CURSHELL" != "/bin/zsh" && "$CURSHELL" != "zsh" ]]; then
#    echo starting default shell
#    echo $SHLVL $CURSHELL
#    default_shell
#else
#    echo zsh is running now
#    echo $SHLVL $CURSHELL
#fi

function bash () {
  env ALLOW_BASH=true bash
}

# TMUX:
# 1st window starts with session "base".
# Next windows with sessions 1,2,... associated with base; these sessions are
# detroyed on shell exit
function tmux_new_window {
local base=$1
export TMUXTOPLEVEL=1
if tmux has-session -t $base; then
    yellow_echo creating new tmux window; sleep 1
    exec tmux new-session -t $base \; new-window
else
    yellow_echo creating new tmux session; sleep 1
    exec tmux new-session -s $base
fi
}

#attach to any detached session
function tmux_attach {
local session="`tmux ls|grep -v '(attached)'|cut -f 1 -d:|head -n1`"
if [ "$session" != "" ]; then
    yellow_echo attaching to session \"$session\"; sleep 1
    exec tmux attach -t "$session"
else
    alert_echo no detached sessions
    sleep 2
    exit
fi
}

#attach to any detached session of group
function tmux_attach_group {
local group=$1
local session="`tmux ls|grep "(group $group)"|grep -v '(attached)'|cut -f 1 -d:|head -n1`"
if [ "$session" != "" ]; then
    yellow_echo attaching to session \"$session\"; sleep 1
    exec tmux attach -t "$session"
else
    alert_echo wrong group number $group - no detached sessions
    sleep 4
    exit
fi
}

function tmux_list_sessions {
local msg
msg="`tmux ls|grep '(attached)'`"
while read -r line; do
    fill_echo $bold$stout$yellow $line
done <<< "$msg"
msg="`tmux ls|grep -v '(attached)'`"
while read -r line; do
    fill_echo $bold$stout$green $line
done <<< "$msg"
}

function x(){
    if [[ "$1" != "" ]]; then
	    echo $1 > ~/.display-x11-$HOSTNAME
    fi
    CMD="export DISPLAY=`cat ~/.display-x11-$HOSTNAME`"
    echo $CMD
    eval $CMD
    echo unset XAUTHORITY
    unset XAUTHORITY
}

function hgrep() {
local pattern="$1"
shift 1
grep --color -E "^|$pattern" $@
}

function show_displays() {
echo local displays:
find /tmp/.X11-unix -type s -printf "%f\t%u\n" | hgrep $USER
echo
echo remote displays:
netstat -lnt | awk '
  sub(/.*:/,"",$4) && $4 >= 6000 && $4 < 6100 {
    print ($1 == "tcp6" ? "ip6-localhost:" : "localhost:") ($4 - 6000)
  }'
echo
}
function set_display() {
show_displays
bold_echo Input display or press enter
local line
read line
x $line
}

alias t=tmux_try_start
function tmux_try_start {
if exist tmux; then
    export TERM=xterm
    if [[ -z $TMUX ]]; then
	set_display
	echo Starting tmux
	if tmux has-session; then
	    echo tmux sessions:
	    tmux_list_sessions
	else
	    bold_echo no tmux sessions
	fi
	mydialog "what to do?
   h - (default) tmux create auxillary session = throwaway =
   	not intended for persistency;
   s - start just shell;
   w - tmux create work session;
   W - tmux attach to work session;
   a - tmux create auxillary session;
   A - tmux attach to auxillary session;
   # - tmux attach group number '#';
   t - tmux atttach any session;
   q - exit" \
	    "h tmux_new_window heap" \
	    "s echo Just shell" \
	    "w tmux_new_window work-base" \
	    "W exec tmux attach -t work-base" \
	    "a tmux_new_window aux-base" \
	    "A exec tmux attach -t aux-base" \
	    "0 tmux_attach_group 0" \
	    "1 tmux_attach_group 1" \
	    "2 tmux_attach_group 2" \
	    "t tmux_attach" \
	    "q exit 0"

    else # we'are in tmux already
	if [ "$TMUXTOPLEVEL" = "1" ]; then
	    echo We are inside tmux
#	    function finish {
#	    session=`tmux display-message -p '#S'`
#	    if [[ $session != "base" ]]; then
#		tmux kill-session -t $session
#	    fi
#	    }
#	    trap finish EXIT
#	    echo On exit window will be closed after end of this shell "(otherwise type \"fin\")"
	    unset TMUXTOPLEVEL
	else
	    echo Just shell
	fi
    fi
else
    echo no tmux in PATH:
    echo $PATH
    set_display
fi
}

# exit without closing session and therefore window
function fin {
function finish {
echo OK
}
exit
}

if [ $inside_ssh ] && [ ! $inside_vnc ]; then
    tmux_try_start
fi
################################################################################
# definitions for interactive work only

function rr {
    local CMD="`fc -ln -1`"
    $XTERMINAL -e $CURSHELL -i -c "$CMD ; bold_echo 'press <Enter> to close the terminal' ; getch" &
}

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
#    alias ls='ls --color=auto'
    function ls {
    /bin/ls --color=always --group-directories-first $@
    }
    function dir {
    ls $@
    }
    function grep {
    command grep --color=auto "$@"
    }
fi
if exist rlwrap; then alias ocaml="rlwrap ocaml"; fi
alias e="emacs -nw"
if exist vimx; then
	alias vi=vimx
	alias vim=vimx
else
	alias vi=vim
fi

function psu {
ps -fU $USER --forest|less
}
function users () {
who -u | grep `date +'%Y-%m-%d'` |  sort -n -k 5
}
function psc {
ps -f --forest | less
}
alias mv='mv -i'
# some more ls aliases
if alias ll &> /dev/null; then
	unalias ll
fi
#alias ll='ls -alF'
function ll {
ls -lhrt --time-style=long-iso $@
}
#this directory
function llthis {
ls -ldhrt --time-style=long-iso $@
}
function la {
ls -A $@
}
function l {
ls -CF $@
}
#sort files by size
function lls {
    ls -lhrS $@
}
# list only directories
function lsd {
  #if [[ "$1" == "" ]]; then ls -d */ .*/ ; else ls -d "$1"/*/ "$1"/.*/ ; fi }
  if [[ "$1" == "" ]]; then
	  ls -d $(echo */) $(echo .*/)
  else
	  ls -d $(echo "$1"/*/) $(echo "$1"/.*/)
  fi
}

function lld {
  setopt nullglob
  if [[ "$1" == "" ]]; then
	  ls -rtdl --time-style=long-iso */ .*/
  else
	  ls -rtdl --time-style=long-iso "$1"/*/ "$1"/.*/
  fi
  unsetopt nullglob
}

alias s="cd .."
alias s2="cd ../.."
alias s3="cd ../../.."
alias s4="cd ../../../.."
alias s5="cd ../../../../.."
alias s6="cd ../../../../../.."
alias s7="cd ../../../../../../.."
alias s8="cd ../../../../../../../.."
alias s9="cd ../../../../../../../../.."

function o {
xdg-open $@
}
if exist ncal; then
alias cal="ncal -y"
fi
alias mypatch="patch -p1 --ignore-whitespace"

# try to decode Microsoft's outlook .msg files
read_msg() {
 strings -e l "$1"|less
}

#ignore cases in search & allow ansi colors
export LESS="-i -R -j20"

GREP_COLOR=always
export LESS_VERSION="$(less -V|head -n1|cut -f2 -d' ')"
if (( $LESS_VERSION <= 381 )); then 
    # old less version seems to have a problem with colors
    GREP_COLOR=never
fi

function p {
cp ~/tmp/buffer ~/tmp/buffer2
tee ~/tmp/buffer|grep --color=$GREP_COLOR -n '^'|less -F -X
cp ~/tmp/buffer ~/tmp/buffer2
}

#   bb   line number   command to filter   command to run
function bb {
if [[ "$1" == "" ]]; then
    cat ~/tmp/buffer|grep --color=$GREP_COLOR -n '^'|less -F -X
else
    local n=$1
    local filter
    filter="$2"
    shift 2
    local line
    local line2
    cat ~/tmp/buffer2|decolorize|head -n $n|tail -n 1| \
	    while read line; do echo line: $line; line2="$line"; done;
    local line_proc
    if [[ "$filter" == "" ]]; then
	    line_proc="$line2"
    else
	    line_proc="`echo $line2 | eval $filter`"
    fi
		if [ -f "$line_proc" ]; then
			ls -l "$line_proc"
		fi
    local cmd
    if [[ "$@" == "" ]]; then
	    cmd=echo
    else
	    cmd="$@"
			echo running:
                        bold_echo $cmd \"$line_proc\"
    fi
		echo
    eval $cmd \"$line_proc\"
fi
}

function trim_spaces() {
     sed "s/^[ \t]*//;s/[ \t]*$//" $@
}

# aliases named b1, b2, ..., b999 to process string as an argument of a
# command:
# > b111 command
#process all line
for i in `seq 1 999`; do alias b$i="bb $i ''"; done
#process first field, e.g. 'x' in 'x:y'
for i in `seq 1 999`; do alias b$i:="bb $i 'cut -f1  -d: | trim_spaces'"; done
for i in `seq 1 999`; do alias :b$i="bb $i 'cut -f2- -d: | trim_spaces'"; done

function lcd() {
cd "$1" && ls | p
}

function lsp() {
ls|p
}

function llp() {
ll|p
}

#TODO: where is fork bomb hidden here in situations:
#f1 f2 f3 "f4 f5"; c2
#f1 f2 f3 "f4 f5"; c2

function get_arg_n() {
echo $#
}

function get_n_arg() {
echo $@[$1+1]
}

function get_last_arg() {
echo $@[$#]
}

function getlast () {
echo call getlast $@
    last_command=$history[$[HISTCMD-1]]
    local arg
    if [[ "$1" == -1 ]]; then
	arg="`eval get_last_arg $last_command`"
    else
	arg="`eval get_n_arg $1 $last_command`"
    fi

    if [[ "$2" == "" ]]; then
	echo $arg
    else
	shift 1
	$* "$arg"
    fi

}

##default pager for man is vim
#export PAGER="/bin/sh -c \"unset PAGER;col -b -x | \
#    vim -R -c 'set ft=man nomod nolist' -c 'map q :q<CR>' \
#    -c 'map <SPACE> <C-D>' -c 'map b <C-U>' \
#    -c 'nmap K :Man <C-R>=expand(\\\"<cword>\\\")<CR><CR>' -c 'set nonumber' -\""

function find_cmd_default () {
  local dir="$1"
  shift 1
  # -H and -xtype f means: follow symlinks if they point to file
  find -H "$dir" -not -wholename "*.hg/*" -not -wholename "*.git/*" -not -wholename "*.svn/*" -xtype f $@
}

function g() {
if [[ "$1" == "" ]]; then
    red_echo no search pattern
    return 1
fi
if [[ "$2" == "" ]]; then
    find_cmd_default . -exec grep -i --color=$GREP_COLOR "$1" \{\} + | p
else
    local dir="$2"
    local pattern="$1"
    shift 2
    find_cmd_default "$dir" -exec grep -i --color=$GREP_COLOR "$pattern" $@ \{\} + | p
fi
}

function gc() {
if [[ "$1" == "" ]]; then
    red_echo no search pattern
    return 1
fi
if [[ "$2" == "" ]]; then
    find_cmd_default . -exec grep --color=$GREP_COLOR "$1" \{\} + | p
else
    local dir="$2"
    local pattern="$1"
    shift 2
    find_cmd_default "$dir" -exec grep --color=$GREP_COLOR "$pattern" $@ \{\} + | p
fi
}

function gg() {
grep --color=$GREP_COLOR -i $@ | p
}

function ggl() {
grep --color=$GREP_COLOR -i -A1 -B6 $@ | p
}

sed_common_cmd="sed -i --follow-symlinks"
# replace all strings in current directory (case insensetive /I), usage:
# > replace str_old str_new
function replace(){
CMD="find_cmd_default . -exec $sed_common_cmd \"s/$1/$2/Ig\" \{\} +"
echo $CMD
eval $CMD
}

#remove line, case insensitive
function remove(){
eval find_cmd_default . -exec $sed_common_cmd "/$1/Id" \{\} +
}

#function showre(){
#find_cmd_default . -exec grep "$1" \{\} +
#}

function findmy {
find . -user $USER
}

function findother {
find . \( -not -user `stat -c "%U" .` -or -not -group `stat -c "%G" .` \) -exec ls -ld --color=always {} +
}

for i in `seq 1 99`; do alias a$i="getlast $i"; done
alias al="getlast -1"

#extract file from grep, "b:" is text before ':', while "a:" is text after ':'
function b:() {
decolorize|cut -f1 -d:
}
function c:() {
decolorize|cut -f2- -d:
}


export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
function gcc_dis () { gcc -m32 -O1 -S $@ -o - | p ; }

function act () {
echo set ~/active to $PWD
ln -sfT "$PWD" ~/active
}

function f() {
local dir
if [[ "$2" == "" ]]; then
	dir=.
else
	dir="$2"/
fi
echo find $dir -iwholename "*$1*"
find $dir -iwholename "*$1*" | p
}

# "findnew N Dir" finds recent files that a newer N days.
# N may be fractionate and by default it is 1/24=1hour.
function findnew() {
local dir
if [[ "$2" == "" ]]; then
	dir=.
else
	dir="$2"/
fi
local time
if [[ "$1" == "" ]]; then
	time=$((1./24))
else
	time="$1"
fi
find $dir -mtime -$time
}


function i1 () {
#parallel -Xj1 --tty $@
read line; eval $@ $line
}

function i () {
while read line; do
    eval $@ $line
done
}

#EXAMPLE:
# f <MATCH> | i vim -O

# highlight data by nice colors
function hi {
pygmentize -O bg=dark -g $@ |p
}

function py {
pygmentize -O bg=dark,python=cool -l python $@ |p
}

function py_compile {
python -m py_compile $@
}

function mdless () {
pandoc -s -f markdown -t man $@ | groff -T utf8 -man | less
}

function zshow {
ls -lart $@
echo md5sum: `md5sum $@`
mydialog "show? [y|n]" "y zcat $@" "n echo OK"
}

function diff () {
    command diff --color=always $@
}

function difftree () {
  colordiff <(cd "$1"; find .|sort) <(cd "$2"; find .|sort)|p
}

function fileinfo () {
  local filename="$1"
  local file_ext=${filename##*.}
  local base="`basename $filename .$file_ext`"
  echo Filename: $filename
  echo File suffix: $file_ext
  echo File basename: $base
}

# determine encoding of a russian TXT file
function enca_rus () {
enca -L russian $@
}

#correct russian encoding after unpacking by unzip
function zip_ru_correct () {
  convmv --notest -r -f cp-1252 -t cp-850 "$1"
  convmv --notest -r -f cp-866 -t utf-8 "$1"
}

function unpack () {
  local filename="$1"
  local file_ext=${filename##*.}
  local base="`basename $filename .$file_ext`"
  case "$file_ext" in
      zip)
      echo Zip archive
      mkdir -p "$base"
      unzip "$filename" -d "$base"
      cd "$base"
      ;;
      rar)
      echo Rar archive
      mkdir -p "$base"
      cd "$base"
      unrar x ../"$filename"
      ;;
  esac
}

function download {
wget -c -t 0 --timeout=60 --waitretry=60 -m $@
}

function site_to_pdf {
local link=$1
local name="`basename $link`"
# recursive, flatten dirs, not get up to parent dirs
wget -r -nd --no-parent "$link" -P "$name"
wkhtmltopdf "$name"/{index.html,*.html} "$name".pdf
}

# Pdf cropping
# - to just crop bottom of pdf file on all pages, do:
#  pdfjam --keepinfo --trim "0mm 15mm 0mm 0mm" --clip true --suffix "cropped" file_to_crop.pdf
# positions mean left bottom right top respectively
# - to crop extra margins, use the following functions:

function all_pdf_crop {
	find . -type f -name "*.pdf" | parallel  pdfcrop3.sh -m 5 {}
}

# functions to echo file and print page count:
mypdfinfo () {
    # -print0 separate files by \0
    # -0      the same for xargs reading
    # -n1     process inputs one by one
    find . -name "*.pdf" -print0 | xargs -0 -I{} -n1 sh -c 'echo; echo "{}"; pdfinfo "{}"'
}

mydjvuinfo () {
    find . -name "*.djvu" -print0 | xargs -0 -I{} -n1 sh -c 'echo; echo "{}"; djvused -e n "{}"'
}

mypsinfo () {
    find . -name "*.ps" -print0 | xargs -0 -n1 -I{} sh -c 'echo; echo "{}"; gs -sDEVICE=bbox -o /dev/null "{}" 2>&1| grep HiResBoundingBox|wc -l'
}

mypdfcrop () {
	file=`mktemp`.pdf
	o "$1"
	bold_echo current file
	ls -l "$1"
	mydialog "Process? [y|n]" "y bold_echo processing" "n return 1"
	if [ $? -ne 0 ]
	then
		return 0
	fi
	pdfcrop3.sh -m 5 "$1" $file
	#pdfcrop.sh "$1" $file
        # the next line may work better:
        # pdfcrop --margins '5 5 5 5' "$1" $file
	o $file
	bold_echo new file
	ls -l $file
	mydialog -warning "Substitute? [y|n]" "y mv -f $file \"$1\"" "n rm $file"
}

# play MTS files from the camera
mplay () {
    # let us handle Ctrl-C manually
    trap ":" INT
    for i in $@
    do
        # deinterlace & fullscreen
        mplayer -vf pp=lb -fs "$i"
        sleep 1
        if [ $? -gt 128 ]; then
            echo
            echo stopped by keyboard
            break
        fi
    done
    trap - INT
}

# helpers for X11
alias m=mysetxkb
alias xm1="xm.sh 1"
alias xm2="xm.sh 2"
alias xm3="xm.sh 3"
alias xm4="xm.sh 4"
alias xm5="xm.sh 5"


###############################################################################
# local.sh can overwite above settings
if [ -f  ~/local.sh ] ; then
echo Load local.sh
. ~/local.sh
fi

# path priorities: my scripts, /usr/local/bin, default PATH, additional paths
export PATH=$HOME/bin:$HOME/activity-personal/computer-program-data/bin:$HOME/opt/bin:/usr/local/bin:$PATH:/usr/local/games:/usr/games:/opt/bin

###############################################################################
# functions for working with version control repositories & others

# Usage : hgdiff file -r rev
hgdiff() {
hg cat $1 $2 $3 $4 $5 $6 $7 $8 $9| vim -g - -c  ":vert diffsplit $1" -c "map q :qa\!<CR>";
}

hgvim() {
vim `hg sta -m -a -r -n $@`
}

hgfix() {
	hg commit -m "never-push work-in-progress `date`. If you see this commit then please notify me about it."
}

hgsea() {
	hg log | gg -C10 $@
}

function hgtagb {
	hg log --rev="branch(`hg branch`) and tag()" --template="{tags}\n"
}

function what_is_repo_type {
if git branch >/dev/null 2>/dev/null; then echo -n git
elif hg root >/dev/null 2>/dev/null; then echo -n mercurial
elif svn info >/dev/null 2>/dev/null; then echo -n svn
else echo -n 'unknown'
fi
}

function report_repo_type {
echo 'repository here ' `pwd` :
bold_echo `what_is_repo_type`
}


function inf {
  REPO=`what_is_repo_type`
  case "$REPO" in
          git) git describe --all; git rev-parse HEAD; git status
		  ;;
          mercurial) hg id; hg paths
		  ;;
	  svn) svn info
		  ;;
	  *) red_echo unknown repository: $REPO

  esac
}

function log {
  REPO=`what_is_repo_type`
  case "$REPO" in
	  git) git log --decorate --graph --all --tags --name-status $@ | less -N
		  ;;
	  mercurial) hg log -v $@ | less -N
		  ;;
	  svn) svn log $@ | less -N
		  ;;
	  *) red_echo unknown repository: $REPO

  esac
}

function his {
  REPO=`what_is_repo_type`
  case "$REPO" in
	  git) git log --follow -p -- $@|p
		  ;;
	  mercurial) hg record $@|p
		  ;;
	  svn) svn log --diff $@|p
		  ;;
	  *) red_echo unknown repository: $REPO

  esac
}

function ann {
  REPO=`what_is_repo_type`
  case "$REPO" in
	  git) git annotate $@|p
		  ;;
	  mercurial) hg ann -b $@
		  ;;
	  svn) svn ann $@|p
		  ;;
	  *) red_echo unknown repository: $REPO

  esac
}

# whether to print version info in PS1
wrepo="none"
function wrepo () {
    if [ "$wrepo" = "none" ]; then
        wrepo="any"
    else
        wrepo="none"
    fi
}

function bra {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git branch | grep \^\* | cut -d ' ' -f2-
          ;;
      mercurial) hg branch
          ;;
      svn) svn info | grep '^URL:' | egrep -o '(tags|branches)/[^/]+|trunk' | egrep -o '[^/]+$'
          ;;
      *) echo -n $REPO
  esac
}

function sta {
  REPO=`what_is_repo_type`
  case "$REPO" in
	  git) git status $@|p
		  ;;
	  mercurial) hg status $@|p
		  ;;
	  svn) svn status $@|p
		  ;;
	  *) red_echo unknown repository: $REPO

  esac
}

function dif {
  REPO=`what_is_repo_type`
  case "$REPO" in
	  git) git diff -r HEAD $@|p
		  ;;
	  mercurial) hg diff $@|p
		  ;;
	  svn) svn diff $@|p
		  ;;
	  *) red_echo unknown repository: $REPO

  esac
}

# show patch for a given revision
function pat {
  REPO=`what_is_repo_type`
  case "$REPO" in
	  git) git show $@|p
		  ;;
	  mercurial) hg diff -c $@|p
		  ;;
	  svn) svn diff -c $@|p
		  ;;
	  *) red_echo unknown repository: $REPO

  esac
}

function add {
for i in $@; do
  cd "`dirname $i`"
  local file="`basename $i`"
  REPO=`what_is_repo_type`
  case "$REPO" in
	  git) git add $file
		  ;;
	  mercurial) hg add $file
		  ;;
	  svn) svn add $file
		  ;;
	  *) red_echo unknown repository: $REPO
  esac
  cd -
done
}

function com {
  REPO=`what_is_repo_type`
  local msg=""
  if [ "$1" != "" ]; then
      msg="-m \"$1\""
  fi
  case "$REPO" in
      git) git add -u :/ && eval git commit $msg && mydialog "push?[n|y]" "n green_echo Done" "y git push origin \"$(bra)\""
          ;;
      mercurial) eval hg commit $msg && (
          if grep default `hg root`/.hg/hgrc &> /dev/null; then
              mydialog "push?" "y hg push" "n green_echo Done"
          else
              yellow_echo no default repository to push
          fi)
          ;;
      svn) eval svn commit $msg
          ;;
      *) red_echo unknown repository: $REPO

  esac
}

function pus {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git push origin "$(bra)"
          ;;
      mercurial) hg push
          ;;
      svn) svn commit
          ;;
      *) red_echo unknown repository: $REPO

  esac
}

pur () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) mydialog "purge?[n|y]" "n green_echo OK" "y git clean  -d  -f -x ."
          # (-d untracked directories, -f untracked files, -x also ignored files)
          ;;
      mercurial) mydialog "purge?[n|y]" "n green_echo OK" "y hg purge"
          ;;
      svn) mydialog "purge?[n|y]" "n green_echo OK" "y svn cleanup . --remove-unversioned"
          ;;
      *) red_echo unknown repository: $REPO

  esac
}

function rvr {
  REPO=`what_is_repo_type`
  case "$REPO" in
	  git) git checkout -- $@
	      #git reset --hard $@
		  ;;
	  mercurial) hg revert $@
		  ;;
	  svn) svn revert $@
		  ;;
  esac
}

# undo add fill
function uad {
  REPO=`what_is_repo_type`
  case "$REPO" in
	  git) git reset $@
		  ;;
	  mercurial) hg revert $@
		  ;;
	  svn) svn revert -R $@
		  ;;
  esac
}

function clo {
  REPO=`what_is_repo_type`
  case "$REPO" in
	  git) git clone --recursive $@
		  ;;
	  mercurial) hg clone $@
		  ;;
	  svn) svn clone $@
		  ;;
  esac
}

# download & update
function pul {
  REPO=`what_is_repo_type`
  case "$REPO" in
	  git) git pull --recurse-submodules origin "$(bra)"
	      git submodule update
		  ;;
	  mercurial) hg pull -u $@
		  ;;
	  svn) svn up $@
		  ;;
  esac
}

# download remote changes
function get {
  REPO=`what_is_repo_type`
  case "$REPO" in
	  git) git fetch --recurse-submodules origin "$(bra)"
		  ;;
	  mercurial) hg pull $@
		  ;;
	  svn) echo not applicable
		  ;;
  esac
}

function upd {
  REPO=`what_is_repo_type`
  case "$REPO" in
	  git) git merge
		  ;;
	  mercurial) hg co $@
		  ;;
	  svn) svn up $@
		  ;;
  esac
}

function mov {
  REPO=`what_is_repo_type`
  case "$REPO" in
	  git) git mv $@
#	  git) git mv -k $@
		  ;;
	  mercurial) hg mv $@
		  ;;
	  svn) svn mv $@
		  ;;
  esac
}

alias d=cd
#function d(){
#if cd $@; then report_repo_type; fi
#}

print_preexec () {
    start_time="`date +'%m-%d %T'`"
    fill_echo $stout $start_time
}

print_precmd () {
       local RESULT=$?
       local finish_time="`date +'%m-%d %T'`"
       local info
       if [[ $finish_time == $start_time ]]; then
           info=". `dirs -p | head -n1`"
       else
           info="$finish_time `dirs -p | head -n1`"
       fi
       #show repository branch if requested
       if [ "$wrepo" != "none" ]; then
           info+=" ($(bra))"
       fi
       if (( $RESULT == 0 )); then
	   fill_echo $stout$cyan "$info"
       elif  (( $RESULT == 127 )); then
	   warning_echo "exit=$RESULT; $info"
       else
	   error_echo "exit=$RESULT; $info"
       fi
}

###############################################################################
# shell-specific settings - for bash or zsh

if [[ "$CURSHELL" == "/bin/zsh" || "$CURSHELL" == "zsh" ]]; then
    echo "zsh detected"
    HISTFILE=~/.histfile
    #almost infinite history for zsh = LONG_MAX
    SAVEHIST=2147483647
    HISTSIZE=$SAVEHIST
    setopt EXTENDED_HISTORY
    bindkey -v
    # backspace in vim's style instead of vi
    bindkey "^?" backward-delete-char
    bindkey "^W" backward-kill-word
    bindkey "^H" backward-delete-char
    # Control-h also deletes the previous char
    bindkey "^U" kill-whole-line
    # home/end in gnome terminal
    bindkey  "^[[H"   beginning-of-line
    bindkey  "^[[F"   end-of-line
    # in putty:
    bindkey  "^[[1~"   beginning-of-line
    bindkey  "^[[4~"   end-of-line
    # (hopefully) in many other terminals:
    bindkey "${terminfo[khome]}" beginning-of-line
    bindkey "${terminfo[kend]}" end-of-line
    # search for the command beginning
    bindkey "${terminfo[kpp]}" history-beginning-search-backward
    bindkey "${terminfo[knp]}" history-beginning-search-forward

    # print function definition in which
    alias which="whence -cvf"

    # tell zsh not to trust its cache when completing
    # There is a performance cost, but it is negligible on a typical desktop
    # setting today. (It isn't if you have $PATH on NFS, or a RAM-starved
    # system.)
    zstyle ":completion:*:commands" rehash 1

    #store vi-mode for next line
    #local mode=vicmd
    local mode=main
    function zle-line-finish {
	mode=$KEYMAP
	#echo -n "$default"
    }
    zle -N zle-line-init
    zle -N zle-line-finish

    function set_prompt {
        # default value for main/viins/"" modes
	local MYPS1="+>"
	if [[ "$KEYMAP" == "vicmd" ]]; then
	    MYPS1=":>"
	fi
	(( cols = $COLUMNS*6/10 ))
	PROMPT="$MYPS1 "
    }

    function mysetfont {
	#echo "]50;xft:Ubuntu Mono:pixelsize=$1"; echo $1;
	TERM=xterm xtermcontrol --font="xft:Ubuntu Mono:pixelsize=$1"
    }

    for i in `seq 0 99`; do alias ff$i="mysetfont $i"; done

    function ff {
        mysetfont 27
	sleep 0.1
        for i in 25 23 21 19 17 `seq 15 -1 6`; do
	    if ((COLUMNS>60)); then break;
	    else mysetfont $i
	    fi
	    sleep 0.1
	done
    }

    function set_font {
        #
	if ((COLUMNS<72)); then mysetfont 7; return; fi
	if ((COLUMNS>100)); then mysetfont 20;return; fi


        #
    }

    set_prompt
    #set_font

    # Reset right prompt, on window resize
    TRAPWINCH ()
    {
	#set_font
	set_prompt
	zle reset-prompt
    }
    function zle-line-init {
    if [[ "$mode" == "vicmd" ]]; then
#    if [[ "$KEYMAP" == "vicmd" ]]; then
	zle vi-cmd-mode
    fi
    set_prompt
    zle reset-prompt
    }

    function zle-keymap-select {
    set_prompt
    zle reset-prompt
    }
    zle -N zle-keymap-select

    # With this widget, you can type `:q<RET>' to exit the shell from vicmd.
    function ft-zshexit {
        [[ -o hist_ignore_space ]] && BUFFER=' '
        BUFFER="${BUFFER}exit"
        zle .accept-line
    }
    zle -N q ft-zshexit
    zle -N ft-zshexit
    bindkey -M vicmd 'ZZ' ft-zshexit

    ##don't use ctrl-d
    #setopt ignore_eof
    #function ft-vi-cmd-cmd() {
    #    zle -M 'Use ZZ or `:q<RET>'\'' in CMD mode to exit the shell.'
    #}
    #
    #zle -N ft-vi-cmd-cmd
    #
    #bindkey -M vicmd '^d' ft-vi-cmd-cmd
    #bindkey '^d' ft-vi-cmd-cmd

#    # reduce ESC delay to 0.1 sec
#    export KEYTIMEOUT=1

    eval "`sed -n 's/^/bindkey /; s/: / /p' /etc/inputrc`" > /dev/null
    case "$TERM" in
	    rxvt-unicode|rxvt-256color) bindkey "\e[7~" beginning-of-line
	    ;;
    esac
    autoload -Uz compinit
    compinit
    # complete 'd' function by directories
    compctl -/ d
    # when completing use the same colors as ls does
    zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
    # skip identical commands
    setopt histignoredups
    # extended pattern matches:
    setopt EXTENDED_GLOB
#    PROMPT=$'%B=%b%? | %* %U%n@%m%u %~%B>%b '
#    PROMPT=$'=%? | %* %U%n@%M%u %~> '
#    PROMPT=$'=%? <%T %w %U%n@%M%u %~> '
    # End of lines added by compinstall
    #alias -s pdf=evince -s ps=evince -s djvu=evince -s fb2=fbreader
    #allow tab completion in the middle of a word
    setopt COMPLETE_IN_WORD

    ## keep background processes at full speed
    #setopt NOBGNICE
    ## restart running processes on exit
    #setopt HUP

    ## history
    #setopt APPEND_HISTORY
    ## for sharing history between zsh processes
    #setopt INC_APPEND_HISTORY
    #setopt SHARE_HISTORY

    ## never ever beep ever
    #setopt NO_BEEP

    ## automatically decide when to page a list of completions
    #LISTMAX=0

    ## disable mail checking
    #MAILCHECK=0

    # autoload -U colors
    #colors
    function preexec() {
      print_preexec
      local a=${${1## *}[(w)1]}  # get the command
      local b=${a##*\/}   # get the command basename
      a="${b}${1#$a}"     # add back the parameters
      a=${a//\%/\%\%}     # escape print specials
      a=$(print -Pn "$a" | tr -d "\t\n\v\f\r")  # remove fancy whitespace
      a=${(V)a//\%/\%\%}  # escape non-visibles and print specials

      case "$TERM" in
        screen|screen.*)
          # See screen(1) "TITLES (naming windows)".
          # "\ek" and "\e\" are the delimiters for screen(1) window titles
          print -Pn "\ek%-3~ $a\e\\" # set screen title.  Fix vim: ".
          print -Pn "\e]2;%-3~ $a\a" # set xterm title, via screen "Operating System Command"
          ;;
        rxvt|rxvt-256color|rxvt-unicode|xterm|xterm-color|xterm-256color)
#          print -Pn "\e]2;$USER@%M:%-3~ $a\a"
          #print -Pn "\e]2;$CURSHELL(%m)> $a\a"
          print -Pn "\e]2;%1/> $a\a"
          ;;
      esac
    }

    preexec

    # set pre-prompt line
    function precmd() {
       local RESULT=$?
       local finish_time="`date +'%m-%d %T'`"
       local info
       if [[ $finish_time == $start_time ]]; then
           info=". `dirs -p | head -n1`"
       else
           info="$finish_time `dirs -p | head -n1`"
       fi
       #show repository branch if requested
       if [ "$wrepo" != "none" ]; then
           info+=" ($(bra))"
       fi
       if (( $RESULT == 0 )); then
	   fill_echo $stout$cyan "$info"
       elif  (( $RESULT == 127 )); then
	   warning_echo "exit=$RESULT; $info"
       else
	   error_echo "exit=$RESULT; $info"
       fi
      case "$TERM" in
        screen|screen.rxvt)
          print -Pn "\ek%-3~\e\\" # set screen title
          print -Pn "\e]2;%-3~\a" # must (re)set xterm title
          ;;
      esac
    }

    # some abbrev.s may be defined in local.sh
    local apu="activity-public"
    local ape="activity-personal"
    typeset -Ag abbreviations
    abbreviations=()

    abbreviations+=(
    "apu"	"$apu/"
    "as"	"activity-shared/"
    "ape"	"$ape/"
    "draf"	"$ape/draft_mak/"
    "wpu"	"works-public/"
    "ws"	"works-shared/"
    "wpe"	"works-personal/"
    "a"		"activity/"
    "ppe"	"physics-particle-experiment/"
    "ppt"	"physics-particle-theory/"
    "qm"	"quantum_mechanics/"
    "qft"	"quantum_field_theory/"
    "pc"	"physics-common/"
    "cml"	"computer-machine_learning/"
    "nlp"	"computer-speech\&natural_languages-processing/"
    "cnm"	"computer-numerical_methods/"
    "cpc"	"computer-program-common/"
    "cps"	"computer-program-system/"
    "cpla"	"computer-program-languages/"
    "cpd"	"$apu/computer-program-data/"
    "cpdo"	"$apu/computer-program-doc/"
    "cpli"	"computer-program-libraries/"
    "cpads"	"computer-program-algorithms_and_data_structures"
    "capp"	"computer-applications/"
    "cpp"	"computer-program-proof/"
    "csym"	"computer-symbolic_calculations_computer_algebra/"
    "cvis"	"computer-visualization/"
    "mal"	"mathematics-algebra-linear/"
    "mc"	"mathematics-common/"
    "mca"	"mathematics-complex_analysis/"
    "md"	"mathematics-discrete/"
    "mfa"	"mathematics-functional_analysis/"
    "mgt"	"mathematics-group_theory/"
    "ml"	"mathematics-logic/"
    "ms"	"mathematics-statistics/"
    "msdp"	"mathematics-statistics&data_processing/"
    "mt"	"mathematics-topology/"
    "mmp"	"mathematics-mathematical_physics/"
    )


    magic-abbrev-expand() {
         local left prefix
         left=$(echo -nE "$LBUFFER" | sed -e "s/[_a-zA-Z0-9]*$//")
         prefix=$(echo -nE "$LBUFFER" | sed -e "s/.*[^_a-zA-Z0-9]\([_a-zA-Z0-9]*\)$/\1/")
         LBUFFER=$left${abbreviations[$prefix]:-$prefix}
    }

#    no-magic-abbrev-expand() {
#        LBUFFER+=' '
#    }

    zle -N magic-abbrev-expand
#    zle -N no-magic-abbrev-expand
#    bindkey " " magic-abbrev-expand
    bindkey "^e" magic-abbrev-expand

else
    if [[ "$CURSHELL" == "/bin/bash" || "$CURSHELL" == "bash" \
       || "$CURSHELL" == "/usr/bin/bash" ]]; then
	echo "bash detected"
    else
	red_echo "unknown shell detected. We suppose it is bash"
    fi
    export HISTTIMEFORMAT=": %s:"
    #infinite history for bash
    export HISTSIZE=""

    export PS1=" > "
    if [ "$TERM" != "" ]; then
        export PS1="\[\033]0;\w\> \$BASH_COMMAND \007\] > "
    fi

    # preexec analogue of zsh for bash using DEBUG hook
    preexec_invoke_exec () {
        [ -n "$COMP_LINE" ] && return  # do nothing if completing
        [ "$BASH_COMMAND" = "$PROMPT_COMMAND" ] && return # don't cause a preexec for $PROMPT_COMMAND
        print_preexec
    }
    trap 'preexec_invoke_exec' DEBUG

    export PROMPT_COMMAND=print_precmd
fi


###############################################################################
# misc functions
# http://www.gentoo.org/doc/en/portage-utils.xml

pkg(){
  local SYSDIST="`os_distribution`"
  if [ "$SYSDIST" = "unknown" ]; then
      red_echo unknown distribution
      return
  fi
  if [[ "$1" == "help" || "$1" == "-h" || "$1" ==  "--help"
        || "$1" == "-help" ]]; then
      echo -e " s"\|"se"\|"search"\\tsearch package name \\n\
	  "i"\\t\\tinstall package \\n\
	  "info"\\t\\tinformation about package \\n\
	  "rm"\\t\\tremove package \\n\
	  "grep"\|"ls"\|"list"\\tlist installed packages \\n\
	  "files"\\t\\tlist files owned by package \\n\
	  "which"\\t\\twhich "  "installed package owns this file\? \\n\
	  "where"\\t\\twhich uninstalled package owns this file\? \\n\
	  "help|-h"\\tthis help
      return
  fi
  case "$SYSDIST" in
      "redhat")
	  case "$1" in
		  "s"|"se"|"search") yum search "$2" ;;
		  "i") yum install "$2" ;;
		  "info") yum info "$2" ;;
		  "rm") yum remove "$2" ;;
		  "grep"|"ls"|"list") rpm -qa "$2";;
		  "files") rpm -ql "$2" ;;
		  "owns"|"which") rpm -qf "$2" ;;
		  "where") yum whatprovides "$2" ;;
		  *) red_echo unknown command "$1"
	  esac
	  ;;
      "debian"|"ubuntu")
	  case "$1" in
		  "s"|"se"|"search") apt-cache search "$2" ;;
		  "i"|"install") apt-get install "$2" ;;
		  "info") apt-cache showpkg "$2" ;;
		  "rm") apt-get remove "$2" ;;
		  "grep"|"ls"|"list") dpkg -l $2 ;;
		  "files") dpkg -L "$2" ;;
	          "owns"|"which") dpkg -S "$2" ;;
	          "where") apt-file search "$2" ;;
		  *) red_echo unknown command "$1"
	  esac
	  ;;
      "gentoo")
	  case "$1" in
		  "s"|"se"|"search") emerge -s "$2" ;;
		  "i"|"install") emerge --ask "$2" ;;
		  "info") emerge -s "$2" ;;
		  "rm") emerge --unmerge "$2" ;;
		  "files") qlist "$2" ;;
		  "grep"|"ls"|"list") equery list '*' ;; #not tested
		  "owns"|"which") qfile "$2" ;;
		  *) red_echo unknown command "$1"
	  esac
	  ;;
      *)  red_echo unknown distribution
	  return
  esac
}

function eline() {
  while read str; do $@ "$str"; done
}

function difstring() {
  cmp -bl  <(echo "$1" ) <(echo "$2")
}

function empty() {
while true; do echo -n y; sleep 5; done;
}
function clock() {
while :
do
    ti=`date +"%r"`
# save current screen postion & attributes
    echo -e -n "\033[7s"
# row 0 and column 69 is used to show clock
    tput cup 0 69
# put clock on screen
    echo -n $ti
# restore current screen postion & attributs
    echo -e -n "\033[8u"
    sleep 1
done
}

### env.variables for correct work of some applications

if exist hg; then
    export HG=`which hg`
fi

# path for latex (final ":" is essential)
export TEXINPUTS=$HOME/activity-public/computer-program-data/latex:

# wrapper for dealing with various file types

function my() {
local FILE="$1"
local DIR=`dirname "$FILE"`
local BASE=`basename "$FILE"`
local EXT=`ext "$FILE"`
local BAS=`basename "$BASE" .$EXT`
case "$EXT" in
    "tex")
	cd $DIR
	pdflatex "$BASE" && o "$BAS.pdf"&
	cd -
	;;
    *)
	red_echo unknown file extension: $EXT
esac
}

###############################################################################
# programs to run in the beginning

if exist /usr/lib/w3m/w3mimgdisplay && \
	[ -d ~/activity-personal/computer-program-data/pictures ] && \
        [[ "$DISPLAY" != "" ]] ; then
clear
dfile=`shuf -n1 -e ~/activity-personal/computer-program-data/pictures/*`
w3disp.sh $dfile
fi

if exist fortune; then
fortune ru
echo
fortune
fi

# to disable sw flow control (ctrl-s, ctrl-q)
#stty stop undef
#stty start undef

###############################################################################
# local.sh can overwite above settings
if [ -f  ~/local-adjust.sh ] ; then
echo Load local-adjust.sh
. ~/local-adjust.sh
fi
