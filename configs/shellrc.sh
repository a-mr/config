
# Contents
# [Init] initialization
# [Secton GUI] functions suitable both for interactive work in graphics(X11)
#              and command line
# [Section CMD] fuctions suitable only for interactive work in command line
# [Section initial screen] programs to run in the beginning

##############################################################################
# [Init]
##############################################################################

##############################################################################
# initial settings
[ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH2_CLIENT" ] \
    && inside_ssh=true
[ -n "$VNCDESKTOP" ] && inside_vnc=true

# Note $SHELL env. variable can be wrong
CURSHELL=`ps -p $$ | tail -1 | awk '{print $NF}'`
CURSHELL=${CURSHELL##*/}  # basename

default_shell () {
if [ -z "$ALLOW_BASH" ] && which zsh > /dev/null 2>&1 && \
    [[ $CURSHELL != zsh ]]; then
    if shopt -q login_shell; then
        echo we are in bash, starting zsh log-in
        case "$BASH_VERSION" in
            5.0.[0-7]"("*)
            echo Bad bash version, spawing another process
            zsh -l ;;
            *) exec zsh -l
        esac
    else
        exec zsh
        echo we are in bash, starting zsh
    fi
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
    # ISO 8601 date format ; regenerate locales by "dpkg-reconfigure locales"
    export LC_TIME=en_DK.UTF-8
else
    export LC_TIME=en_US.UTF-8
fi

##############################################################################
# [Section GUI]
##############################################################################

export EXDR="`myextdrive`"
# fix latest Debian Chromium disabling remote extensions
export CHROMIUM_FLAGS=$CHROMIUM_FLAGS" --enable-remote-extensions"

# there are only simple alias-like functions for shell convenience here

if exist vimx; then
    export EDITOR=vimx
else
    export EDITOR=vim
fi

if [ -z "$SSH_CONNECTION" ]; then
    export BROWSER=firefox
else
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
ta () {
  textadept $@
}

tac () {
  textadept-curses $@
}

# compile & start Nim app
ncr () {
    nim c $1
    if [ $? -eq 0 ]; then
        local bname=${1%.nim}               # strip extension .nim
        if [ "${DIR:0:1}" != "/" ]; then
            bname=./$bname
        fi
        bold_echo running $bname
        $bname
    fi
}

# the same, with threads
nctr () {
    nim c --threads:on $1
    if [ $? -eq 0 ]; then
        local bname=${1%.nim}               # strip extension .nim
        if [ "${DIR:0:1}" != "/" ]; then
            bname=./$bname
        fi
        bold_echo running $bname
        $bname
    fi
}

# compile nim compiler (with debugging) as nim2 (FAST way)
mknimdbg () {
    nim c --lib:lib --debuginfo --lineDir:on -o:$HOME/activity-shared/Nim/bin/nimdbg $HOME/activity-shared/Nim/compiler/nim.nim
}
[[ $CURSHELL == bash ]] && export -f mknimdbg

nimrebuild () {
    rm -rf csources bin/nim bin/nim_csources
    sh build_all.sh
}

#julia
julianb () {
    julia -e "using IJulia; notebook()"
}

# compile & start kotlin file
mykt () {
    local bname="`basename \"$1\" .kt`"
    kotlinc "$bname.kt" -include-runtime -d "$bname.jar"
    if [ $? -eq 0 ]; then
        echo running $bname.jar
        java -jar "$bname.jar"
    fi
}

rednotebook () {
    ~/activity-public/rednotebook/run $@
}

REDNOTEBOOK_DIR="$HOME/activity-personal/draft_mak"
if [ ! -d "$REDNOTEBOOK_DIR" ]; then
    REDNOTEBOOK_DIR="$EXDR/MAKAROV/activity-personal/draft_mak"
fi

# misc.aliases
wd () {
    rednotebook "$REDNOTEBOOK_DIR/work_diary"
}
pd () {
    rednotebook "$REDNOTEBOOK_DIR/personal_diary"
}

c () {
    echo $@|bc -l
}

untar () {
    # do not try to change times
    tar zxvf $@ --no-overwrite-dir
}

fm () {
    thunar
}

if exist icedove && ! exist thunderbird; then
    thunderbird () {
        icedove
    }
fi

android_connect () {
    mtpfs -o allow_other ~/tmp/note
}
android_disconnect () {
    fusermount -u ~/tmp/note
}
yandex () {
    mkdir -p $HOME/mnt/yandex.disk
    sudo mount -t davfs -o gid=$GID,uid=$UID https://webdav.yandex.ru $HOME/mnt/yandex.disk
}
uyandex () {
    sudo umount $HOME/mnt/yandex.disk
}

# list processes using the mount dir
use () {
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

syn () {
    bold_echo rsync dry run
    # slash "/" after "$1" is essential
    rsync -rvCn --size-only "$1/" "$2"
    mydialog -warning "Proceed? [y|n]" \
        "y rsync -rvC --size-only \"$1/\" \"$2\"" \
        "n bold_echo doing nothing"
}

#version with delete
synd () {
    bold_echo rsync dry run
    # slash "/" after "$1" is essential
    rsync -rvCn --delete --size-only "$1/" "$2"
    mydialog -warning "Proceed? [y|n]" \
        "y rsync -rvC --delete --size-only \"$1/\" \"$2\"" \
        "n bold_echo doing nothing"
}

##############################################################################
# [Section CMD]
##############################################################################

# If not running interactively, don't do anything else
if [ -z "$PS1" ]; then
    return
fi

if [[ "$ONLYREADCONF" == "y" ]]; then
    return
fi

bash () {
  env ALLOW_BASH=true bash
}

# TMUX:
# 1st window starts with session "base".
# Next windows with sessions 1,2,... associated with base; these sessions are
# detroyed on shell exit
tmux_new_window () {
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
tmux_attach () {
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
tmux_attach_group () {
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

tmux_list_sessions () {
    local msg
    msg="`tmux ls|grep '(attached)'`"
    echo "$msg" | while read -r line; do
        fill_echo $bold$stout$yellow $line
    done
    msg="`tmux ls|grep -v '(attached)'`"
    echo "$msg" | while read -r line; do
        fill_echo $bold$stout$green $line
    done
}

# try to set ssh agent (mostly) silently
pickup_ssh_agent () {
    # define SSH_AUTH_SOCK & SSH_AGENT_PID
    [ -f ~/.ssh/myagent.sh ] && . ~/.ssh/myagent.sh
    if [[ ! -z $SSH2_AUTH_SOCK ]]; then
        local socket="$SSH2_AUTH_SOCK"
    fi
    if [[ ! -z $SSH_AUTH_SOCK ]]; then
        local socket="$SSH_AUTH_SOCK"
    fi
    if [[ -S "$socket" ]] && ps -p $SSH_AGENT_PID > /dev/null; then
        echo ssh-agent is already present at $socket, use it
    else
        if [[ -S "$socket" ]]; then
            echo remove $socket
            rm $socket
        fi
        echo no ssh agent in ~/.ssh/myagent.sh
    fi
}

ensure_ssh_agent () {
    # define SSH_AUTH_SOCK & SSH_AGENT_PID
    . ~/.ssh/myagent.sh
    if [[ ! -z $SSH2_AUTH_SOCK ]]; then
        local socket="$SSH2_AUTH_SOCK"
    fi
    if [[ ! -z $SSH_AUTH_SOCK ]]; then
        local socket="$SSH_AUTH_SOCK"
    fi
    if [[ -S "$socket" ]] && ps -p $SSH_AGENT_PID > /dev/null; then
        echo ssh-agent is already present at $socket, use it
    else
        if [[ -S "$socket" ]]; then
            echo remove $socket
            rm $socket
        fi
        warning_echo no ssh agent in ~/.ssh/myagent.sh
        mydialog "start ssh-agent? [n|y]" "n echo OK" \
            "y ssh-agent > ~/.ssh/myagent.sh; . ~/.ssh/myagent.sh; ssh-add"
    fi
}

alias ss=ensure_ssh_agent

# just highlight matches, not filter them out
hgrep () {
    local pattern="$1"
    shift 1
    grep --color -E "^|$pattern" $@
}

show_displays () {
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

set_display () {
    show_displays
    bold_echo Input display or press enter
    local line
    read line
    x $line
}

tmux_try_start () {
    if exist tmux; then
        #export TERM=xterm
        if [[ -z $TMUX && -z $IN_SCREEN ]]; then
            set_display
            ensure_ssh_agent
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
       b - start bash;
       w - tmux create work session;
       W - tmux attach to work session;
       a - tmux create auxillary session;
       A - tmux attach to auxillary session;
       # - tmux attach group number '#';
       t - tmux atttach any session;
       q - exit" \
           "h tmux_new_window heap" \
           "s echo Just shell" \
           "b exec bash" \
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

screen_try_attach () {
    local session_type=${1:-"("}
    local session="`screen -list | grep "$session_type" | awk '{print $1}'`"
    if [ -z $session ]; then
        echo no session type $session_type
        return 1
    fi
    screen -r "$session"
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        sleep 2
        exit
    fi
    return $exit_code
}

screen_try_start () {
    if exist screen; then
        #export TERM=xterm
        if [[ -z $TMUX && -z $IN_SCREEN ]]; then
            export IN_SCREEN=1
            set_display
            ensure_ssh_agent
            echo Starting screen
            # display all the lines ('^') but highlight selected words
            screen -list | grep --color=always -e '^' \
                -e aux -e work -e Attached -e Detached
            mydialog "what to do?
       a - (default) Screen create auxillary session = throwaway =
           not intended for persistency;
       A - Screen attach to auxillary session;
       s - start just shell;
       b - start bash;
       w - Screen create work session;
       W - Screen attach to work session;
       t - Screen atttach any session;
       q - exit" \
           "h exec screen -S aux" \
           "s echo Just shell" \
           "b exec bash" \
           "w exec screen -S work" \
           "W screen_try_attach work" \
           "a exec screen -S aux" \
           "A screen_try_attach aux" \
           "t screen_try_attach" \
           "q exit 0"

        else # we'are in tmux already
            echo Just shell
        fi
    else
        echo no screen in PATH:
        echo $PATH
        set_display
    fi
}

pickup_ssh_agent

# exit without closing session and therefore window
fin () {
    finish () {
        echo OK
    }
    exit
}

if [ $inside_ssh ] && [ ! $inside_vnc ] && [ -z $ALLOW_BASH ]; then
    #tmux_try_start
    screen_try_start
fi
##############################################################################
# definitions for interactive work only

# rename current tmux window and move it to the specified number
# tt _ 7     # move window to 7
# tt Name 7  # move window to 7 and rename to "Name"
tt () {
    if [[ "$1" == "" ]]; then
        echo "Current pane:"
        tmux display-message -p '#I : #W #H   pane_id=#D   pane_index=#P   session=#S'
        echo
    else
        if [[ "$1" != "_" ]]; then
            tmux rename-window "$1"
        fi
        if [[ "$2" != "" ]]; then
            tmux swap-window -t "$2"
        fi
    fi
    tmux list-panes -aF "#{window_index}	#{pane_tty}	#{window_name}"
}

rr () {
    local CMD="`fc -ln -1`"
    $XTERMINAL -e $CURSHELL -i -c "$CMD ; bold_echo 'press <Enter> to close the terminal' ; getch" &
}

unalias ls 2> /dev/null
unalias dir 2> /dev/null
unalias grep 2> /dev/null
unalias la 2> /dev/null
unalias l 2> /dev/null
unalias o 2> /dev/null

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    ls () {
        /bin/ls --color=always --group-directories-first $@
    }
    dir () {
        ls $@
    }
    grep () {
        command grep --color=auto "$@"
    }
fi

if exist vimx; then
    alias vi=vimx
    alias vim=vimx
else
    alias vi=vim
fi

v () {
    vim -p $@
}
# show my shortcuts
k () {
    vim ~/activity-public/computer-program-data/configs/shortcuts.txt
}
t () {
    vim ~/tips/tips.txt
}
# note taking
n () {
    ~/bin/notes.sh
}
# file manager with cd
vf () {
   # from https://wiki.vifm.info/index.php?title=How_to_set_shell_working_directory_after_leaving_Vifm
   # Syncro vifm and shell
   local dst="$(command vifm --choose-dir - .)"
   if [ -z "$dst" ]; then
      echo 'Directory picking cancelled/failed'
      return 1
   fi
   cd "$dst"
}

psu () {
    ps -f --forest -u ${1:-$USER} | less
}
psa () {
    ps ao stat,euid,ruid,tty,tpgid,sess,pgrp,ppid,pid,pcpu,comm --forest ${@-a} | less
}
pst () {
    ps o user,pid,comm --forest ${@-a} | less
}
users () {
    who -u | grep `date +'%Y-%m-%d'` |  sort -n -k 5
}
psc () {
    ps -f --forest | less
}
tree () {
    command tree -C --charset utf8 $@ | less
}
alias mv='mv -i'
# some more ls aliases
if alias ll > /dev/null 2>&1; then
    unalias ll
fi

ll () {
    ls -lhrt --time-style=long-iso $@
}
#this directory
llthis () {
    ls -ldhrt --time-style=long-iso $@
}
la () {
    ls -A $@
}
l () {
    ls -CF $@
}
#sort files by size
lls () {
    ls -lhrS $@
}
# list only directories
lsd () {
  if [[ "$1" == "" ]]; then
      ls -F . | grep '/$'
  else
      ls -F "$1" | grep '/$'
  fi
}

lsda () {
  if [[ "$1" == "" ]]; then
      ls -aF . | grep '/$'
  else
      ls -aF "$1" | grep '/$'
  fi
}

lld () {
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

# notify/alarm me about a last finished command
a () {
    local last
    if [[ $CURSHELL == zsh ]]; then
        last=$history[$HISTCMD]
    else
        last="$(HISTTIMEFORMAT="%H:%M:%S     " history 1)"
    fi
    if exist notify-send; then
        notify-send "command finished: $last"
    fi
    echo -ne \\a
}

o () {
    if exist mimeopen; then
        mimeopen $@
    elif exist xdg-open; then
        xdg-open $@
    else
        red_echo neither mimeopen nor xdg-open exists
    fi
}
if exist ncal; then
    alias cal="ncal -y -w"
fi
alias mypatch="patch -p1 --ignore-whitespace"

# try to decode Microsoft's outlook .msg files
read_msg () {
 strings -e l "$1"|less
}

#ignore cases in search & allow ansi colors
export LESS="-i -R -j20"

GREP_COLOR=always
export LESS_VERSION="$(less -V|head -n1|cut -f2 -d' ')"
if [ "$LESS_VERSION" -lt "381" ]; then 
    # old less version seems to have a problem with colors
    GREP_COLOR=never
fi

# Use:
# - buffer for directing multi-line outputs
# - buffer2 for directing one-line outputs (like a long path)

# pager with line numbers which copies to a file
p () {
    # add -F to exit less if it fits the screen
    tee ~/tmp/buffer | less -N -X
}

# just print to buffer
pb () {
    # -E means exit at reaching EOF
    tee ~/tmp/buffer | less -N -X -E
}

# simple pager with line number
pp () {
    cat -n | less -X
}

lsdirs () {
  ( fullpath; echo ./; echo ../; lsd ) | \
      tee ~/tmp/buffer | cat -n | less -X -F
}

ee () {
  local dir=${1:-.}
  cd "$dir"
  lsdirs
  local num
  while true; do
      echo -n "$bold =============================[q|ls|p|#]>$reset "
      read num
      case "$num" in
        "") ls | p
            return
            ;;
        "q") return ;;
        "ls") ls ;;
        "p") lsdirs ;;
        *) echo selected $num
           break
           # red_echo unknown command $num ;;
      esac
  done
  local line2="$(cat ~/tmp/buffer|decolorize|head -n $num|tail -n 1)"
  ee "$line2"
}

eea () {
  local dir=${1:-.}
  cd "$dir"
  (fullpath; lsda) | tee ~/tmp/buffer | cat -n | less -X -F
  echo -n "$bold =============================>$reset "
  local num
  read num
  if [[ $num == "" ]]; then
      ls -a
      return
  fi
  if [[ $num == "q" ]]; then
      return
  fi
  local line2="$(cat ~/tmp/buffer|decolorize|head -n $num|tail -n 1)"
  eea "$line2"
}

# use ~/tmp/buffer2 for passing one-line information from
# one command (fullpath,..) to another - argument of b
b () {
    if [[ "$1" == "" ]]; then
        cat ~/tmp/buffer2
    else
        local line_proc=$(cat ~/tmp/buffer2)
        cmd="$@"
        echo running:
        bold_echo $cmd \"$line_proc\"
        add_command $cmd \"$line_proc\"
        eval $cmd \"$line_proc\"
    fi
}

setb () {
    echo $@ > ~/tmp/buffer2
}

#   bb   `line number`   `command to filter`   `command to run`
bb () {
  if [[ "$1" == "" ]]; then
    # less: -X don't clear the screen, -F quit if one screen
    cat ~/tmp/buffer|less -F -N -X
  else
    local n=$1
    local filter
    filter="$2"
    shift 2
    local line2="$(cat ~/tmp/buffer|decolorize|head -n $n|tail -n 1|trim_spaces)"
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
    add_command $cmd \"$line_proc\"
    eval $cmd \"$line_proc\"
  fi
}

#open file +line in vim
bv () {
    if [[ "$1" == "" ]]; then
        local n=1
    else
        local n=$1
    fi
    filter="$2"
    local line="$(cat ~/tmp/buffer|decolorize|head -n $n|tail -n 1)"
    echo \ \ line:	$line
    local line_proc
    if [[ "$filter" == "" ]]; then
        line_proc="$line"
    else
        line_proc="`echo $line | eval $filter`"
    fi
    # /bin/echo is used since zsh echo interprets escapes like '\n' by default
    local fname="$(/bin/echo $line_proc | cut -f1 -d: | trim_spaces)"
    local lineNo="$(/bin/echo $line_proc: | cut -f2 -d: | trim_spaces)"
    echo \ \ fname:	$fname
    echo \ \ lineN:	$lineNo
    if [[ "$lineNo" == "" ]]; then
        echo vim \'$fname\'
        add_command vim \'$fname\'
        eval vim \'$fname\'
    else
        echo vim \'$fname\' +$lineNo
        add_command vim \'$fname\' +$lineNo
        eval vim \'$fname\' +$lineNo
    fi
}

trim_spaces () {
    sed "s/^[ \t]*//;s/[ \t]*$//" $@
}

# aliases named b1, b2, ..., b999 to process string as an argument of a
# command:
# > b111 command
#process all line
for i in `seq 1 999`; do alias b$i="bb $i ''"; done
#alias to open file +line in vim
for i in `seq 1 999`; do alias bv$i="bv $i"; done
#process first field, e.g. 'x' in 'x:y'
for i in `seq 1 999`; do alias b${i}l="bb $i 'cut -f1  -d: | trim_spaces'"; done
for i in `seq 1 999`; do alias b${i}r="bb $i 'cut -f2- -d: | trim_spaces'"; done
for i in `seq 1 999`; do alias bv${i}l="bv $i 'cut -f1  -d: | trim_spaces'"; done
for i in `seq 1 999`; do alias bv${i}r="bv $i 'cut -f2- -d: | trim_spaces'"; done
for i in `seq 1 999`; do alias o$i="bb $i '' o"; done

lcd () {
    cd "$1" && ls | p
}

lsp () {
    ls|p
}

llp () {
    ll|p
}

#TODO: where is fork bomb hidden here in situations:
#f1 f2 f3 "f4 f5"; c2
#f1 f2 f3 "f4 f5"; c2

get_arg_n () {
    echo $#
}

get_n_arg () {
    echo $@[$1+1]
}

get_last_arg () {
    echo $@[$#]
}

# get argument of previous command:
# ls a2 a3
# getlast 1 -> ls
# getlast 2 -> a2
# getlast 3 -> a3
# getlast -1 -> a3
getlast () {
    #echo call getlast $@
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

man () {
    nvim -c 'let no_man_maps = 1' -c 'runtime ftplugin/man.vim' \
        -c 'map q :q<CR>' \
        -c 'set nolist' \
        -c "Man $@" -c 'wincmd o'
}

find_cmd_default () {
    local dir="$1"
    shift 1
    # -H and -xtype f means: follow symlinks if they point to file
    find -H "$dir" -not -wholename "*.hg/*" -not -wholename "*.git/*" \
        -not -wholename "*.svn/*" -xtype f $@
}

gi () {
    if [[ "$1" == "" ]]; then
        red_echo no search pattern
        return 1
    fi
    local pattern="$1"
    if [[ "$2" == "" ]]; then
        local dir=.
        shift 1
    else
        local dir="$2"
        shift 2
    fi
    grep --color=$GREP_COLOR "$pattern" --exclude-dir=.git --exclude-dir=.svn \
         --exclude-dir=.hg -inr "$dir" $@ | p
}


# case-sensitive, with color
gc () {
    if [[ "$1" == "" ]]; then
        red_echo no search pattern
        return 1
    fi
    local pattern="$1"
    if [[ "$2" == "" ]]; then
        local dir=.
        shift 1
    else
        local dir="$2"
        shift 2
    fi
    grep --color=$GREP_COLOR "$pattern" --exclude-dir=.git --exclude-dir=.svn \
         --exclude-dir=.hg -nr "$dir" $@ | p
}

ngcommon () {
    nimgrep --color=$GREP_COLOR --colortheme:ack --recursive \
        --excludeDir:"\.git$" --excludeDir:"\.hg$" --excludeDir:"\.svn$" \
        --cols:$((COLUMNS-8)) --onlyAscii -j:4 $@
}

# search in Nim files, style-insensitive (-y)
nng () {
    if [[ "$1" == "" ]]; then
        red_echo no search pattern
        return 1
    fi
    local pattern="$1"
    if [[ "$2" == "" ]]; then
        local dir=.
        shift 1
    else
        local dir="$2"
        shift 2
    fi
    ngcommon -y --ext:nim\|nims $pattern $dir $@ | p
}

# search using nimgrep
ngc () {
    if [[ "$1" == "" ]]; then
        red_echo no search pattern
        return 1
    fi
    local pattern="$1"
    if [[ "$2" == "" ]]; then
        local dir=.
        shift 1
    else
        local dir="$2"
        shift 2
    fi
    ngcommon $pattern $dir $@ | p
}

# search using nimgrep, case-insensitive
ngi () {
    if [[ "$1" == "" ]]; then
        red_echo no search pattern
        return 1
    fi
    local pattern="$1"
    if [[ "$2" == "" ]]; then
        local dir=.
        shift 1
    else
        local dir="$2"
        shift 2
    fi
    ngcommon -i $pattern $dir $@ | p
}

# case-sensitive, with color, check that 2 strings are available in file:
# g2c string1 "string2" directory
# only string2 will be displayed in lines of output
g2c () {
    if [[ "$1" == "" || "$2" == "" ]]; then
        red_echo no search pattern
        return 1
    fi
    local pattern1="$1"
    local pattern2="$2"
    if [[ "$3" == "" ]]; then
        local dir=.
        shift 1
    else
        local dir="$2"
        shift 2
    fi
    grep "$pattern1" --exclude-dir=.git --exclude-dir=.svn \
         --exclude-dir=.hg -lZr "$dir" | \
         xargs -0 grep -n "$pattern2" --color=$GREP_COLOR | p
}

# case-sensitive, no-color
gcm () {
    if [[ "$1" == "" ]]; then
        red_echo no search pattern
        return 1
    fi
    local pattern="$1"
    if [[ "$2" == "" ]]; then
        local dir=.
        shift 1
    else
        local dir="$2"
        shift 2
    fi
    grep --color=never "$pattern" --exclude-dir=.git --exclude-dir=.svn \
         --exclude-dir=.hg -nr "$dir" $@ | p
}

# case-sensitive, whole-word
gcw () {
    if [[ "$1" == "" ]]; then
        red_echo no search pattern
        return 1
    fi
    local pattern="$1"
    if [[ "$2" == "" ]]; then
        local dir=.
        shift 1
    else
        local dir="$2"
        shift 2
    fi
    grep --color=$GREP_COLOR "$pattern" --exclude-dir=.git --exclude-dir=.svn \
         --exclude-dir=.hg -wnr "$dir" $@ | p
}

gg () {
    grep --color=$GREP_COLOR -i $@ | p
}

ggl () {
    grep --color=$GREP_COLOR -i -A1 -B6 $@ | p
}

sed_common_cmd="sed -i --follow-symlinks"
# replace all strings in current directory (case insensetive /I), usage:
# > replace str_old str_new
replace () {
    CMD="find_cmd_default . -exec $sed_common_cmd \"s/$1/$2/Ig\" \{\} +"
    echo $CMD
    eval $CMD
}

#remove line, case insensitive
remove () {
    eval find_cmd_default . -exec $sed_common_cmd "/$1/Id" \{\} +
}

# Remove line after $3 lines after pattern ($1)
# $1 - pattern
# $2 - num lines to skip
# $3 - path to file
remove_skip () {
    if [[ ! -f $3 ]]; then
        red_echo no file name given
        return
    fi
    line_num=$(grep -n "$1" "$3" | grep -Eo '^[^:]+')
    if [[ "$line_num" == "" ]]; then
        echo no line found for file $3
        return
    fi
    let line_num+=$2
    sed -i "$line_num d" "$3"
}

findmy () {
    find . -user $USER
}

findother () {
    find . \( -not -user `stat -c "%U" .` -or -not -group `stat -c "%G" .` \) \
        -exec ls -ld --color=always {} +
}

for i in `seq 1 99`; do alias a$i="getlast $i"; done
alias al="getlast -1"

#extract file from grep, "bl" is text before ':', while "br" is text after ':'
bl () {
    decolorize|cut -f1 -d:
}
br () {
    decolorize|cut -f2- -d:
}


export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
gcc_dis () { gcc -m32 -O1 -S $@ -o - | p ; }

# see open file descriptors for the process $1
opfd () {
    ll /proc/$1/fd
}

makes () {
    make -qp | awk -F':' \
        '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ {split($1,A,/ /);for(i in A)print A[i]}' | \
        sort -u | less
}

act () {
    echo set ~/active to $PWD
    ln -sfT "$PWD" ~/active
}

f () {
    local dir
    if [[ "$2" == "" ]]; then
        dir=.
    else
        dir="$2"/
    fi
    echo find $dir -iwholename "*$1*"
    find $dir -iwholename "*$1*" | p
}

find_writable_dir () {
    find "$1" -type d -print0 | while IFS= read -d $'\0' -r dir ; do
        if [ -w "$dir" ]; then
            echo -n "WRITABLE ";
        else
            echo -n "NOT WRITABLE ";
        fi;
        ls -ld "$dir";
    done | less
}

# "findnew Dir N" finds recent files that a newer N days.
# N may be fractionate and by default it is 1/24=1hour.
findnew () {
    local dir
    if [[ "$1" == "" ]]; then
        dir=.
    else
        dir="$1"/
    fi
    local time
    if [[ "$2" == "" ]]; then
        time=$(c 1./24)
    else
        time="$2"
    fi
    find $dir -mtime -$time | p
}

# sort files by modification time
findtime () {
    find . -printf "%T@ %Tc %p\n" $@ | sort -n | cut -f2- -d' '
}

findbig () {
    local dir
    if [[ "$1" == "" ]]; then
        dir=.
    else
        dir="$1"/
    fi
    find "$dir" -type f -printf "%s\t%p\n" | sort -nr | less
}

i1 () {
    #parallel -Xj1 --tty $@
    read line; eval $@ $line
}

i () {
    while read line; do
        eval $@ $line
    done
}

#EXAMPLE:
# f <MATCH> | i vim -O

# highlight data by nice colors
hi () {
    pygmentize -O bg=dark -g $@ |p
}

py () {
    pygmentize -O bg=dark,python=cool -l python $@ |p
}

py_compile () {
    python -m py_compile $@
}

# show markdown file as a man page
mdless () {
    pandoc -s -f markdown -t man $@ | groff -T utf8 -man | less
}

zshow () {
    ls -lart $@
    echo md5sum: `md5sum $@`
    mydialog "show? [y|n]" "y zcat $@" "n echo OK"
}

diff () {
    command diff --color=always $@
}

# print binary file one byte value per line
hexd () {
    hexdump -v -e '/1 "0x%02x\n"' $@
}

if exist gdate; then
curtime () {
	gdate +%s.%N
}
else
curtime () {
	date +%s.%N
}
fi

if [[ $CURSHELL == bash || $CURSHELL == zsh ]]; then
    . $HOME/.functions_advanced.sh
fi

fileinfo () {
    local filename="$1"
    local file_ext=${filename##*.}
    local base="`basename $filename .$file_ext`"
    echo Filename: $filename
    echo File suffix: $file_ext
    echo File basename: $base
}

# determine encoding of a russian TXT file
enca_rus () {
    enca -L russian $@
}

#correct russian encoding after unpacking by unzip
zip_ru_correct () {
    convmv --notest -r -f cp-1252 -t cp-850 "$1"
    convmv --notest -r -f cp-866 -t utf-8 "$1"
}

unpack () {
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

download () {
    wget -c -t 0 --timeout=60 --waitretry=60 -m $@
}

site_to_pdf () {
    local link=$1
    local name="`basename $link`"
    # recursive, flatten dirs, not get up to parent dirs
    wget -r -nd --no-parent "$link" -P "$name"
    wkhtmltopdf "$name"/{index.html,*.html} "$name".pdf
}

vimprint () {
    local output="$1.ps"
    vim -c ":set printoptions=paper:A4,left:18mm,right:2mm,top:5mm,bottom:5mm" -c "hardcopy > $output" -c quit "$1"
    o "$output"
    rm "$output"
}

vimpdf () {
    local output="$1.ps"
    vim -c ":set printoptions=paper:A4,left:2mm,right:2mm,top:2mm,bottom:2mm" -c "hardcopy > $output" -c quit "$1"
    local output2="$1.pdf"
    ps2pdf "$output" "$output2"
    rm "$output"
    echo $output2 | pb
    o "$output2"
}

vimpdfB5 () {
    local output="$1.ps"
    vim -c ":set printoptions=paper:B5,left:2mm,right:2mm,top:2mm,bottom:2mm" -c "hardcopy > $output" -c quit "$1"
    local output2="$1.pdf"
    ps2pdf "$output" "$output2"
    rm "$output"
    echo $output2 | pb
    o "$output2"
}

tolatex () {
  local FILE="$1"
  local BASE=`basename "$FILE"`
  local EXT=`ext "$FILE"`
  local BAS=`basename "$BASE" .$EXT`
  pandoc "$FILE" -t latex -s \
      -V twoside,twocolumn,top=10mm,bottom=20mm,left=30mm,right=6mm \
      --number-sections --extract-media tmp_images -o "tmp/$BAS.tex"
  mv tmp_images tmp
}

# Pdf cropping
# - to just crop bottom of pdf file on all pages, do:
#  pdfjam --keepinfo --trim "0mm 15mm 0mm 0mm" --clip true --suffix "cropped" file_to_crop.pdf
# positions mean left bottom right top respectively
# - to crop extra margins, use the following functions:

all_pdf_crop () {
    find . -type f -name "*.pdf" | parallel  pdfcrop3.sh -m 5 {}
}

# for two side printing: add left margin for odd/even pages
twoside () {
  file=${2:-`mktemp`.pdf}
  # 40 pts means ~ 1.45cm
  gs -q -sDEVICE=pdfwrite -dBATCH -dNOPAUSE -sOutputFile="$file" \
  -dDEVICEWIDTHPOINTS=623 -dDEVICEHEIGHTPOINTS=842 -dFIXEDMEDIA \
  -c "<< /CurrPageNum 1 def /Install { /CurrPageNum CurrPageNum 1 add def
   CurrPageNum 2 mod 0 eq {40 0 translate} {-40 0 translate} ifelse } bind  >> setpagedevice" \
  -f "$1"

   o $file
   [ -z "$2" ] && rm $file || echo Output to file $2
}

# functions to echo file and print page count:
mypdfinfo () {
    # -print0 separate files by \0
    # -0      the same for xargs reading
    # -n1     process inputs one by one
    find . -name "*.pdf" -print0 | \
        xargs -0 -I{} -n1 sh -c 'echo; echo "{}"; pdfinfo "{}"'
}

mydjvuinfo () {
    find . -name "*.djvu" -print0 | \
        xargs -0 -I{} -n1 sh -c 'echo; echo "{}"; djvused -e n "{}"'
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
    o $file
    bold_echo new file
    ls -l $file
    mydialog -warning "Substitute? [y|n]" "y mv -f $file \"$1\"" "n rm $file"
}

# the same but with enough space for `twoside` (odd/even page fixer)
mypdfcrop2 () {
    file=`mktemp`.pdf
    o "$1"
    bold_echo current file
    ls -l "$1"
    mydialog "Process? [y|n]" "y bold_echo processing" "n return 1"
    if [ $? -ne 0 ]
    then
        return 0
    fi
    pdfcrop3.sh -m "5 35 5 32" "$1" $file
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


##############################################################################
# local.sh can overwite above settings
if [ -f  ~/local.sh ] ; then
    echo Load local.sh
    . ~/local.sh
fi

# path priorities: my scripts, /usr/local/bin, default PATH, additional paths
export PATH=$HOME/bin:$HOME/activity-personal/computer-program-data/bin:$HOME/opt/bin:/usr/local/bin:$PATH:/usr/local/games:/usr/games:/opt/bin

##############################################################################
# functions for working with version control repositories & others

# fetch & checkout Github PR
github () {
    git fetch origin pull/$1/head:pr/$1
    git co pr/$1
}

# Usage : hgdiff file -r rev
hgdiff () {
    hg cat $1 $2 $3 $4 $5 $6 $7 $8 $9| vim -g - -c  ":vert diffsplit $1" -c "map q :qa\!<CR>";
}

hgvim () {
    vim `hg sta -m -a -r -n $@`
}

hgfix () {
    hg commit -m "never-push work-in-progress `date`. If you see this commit then please notify me about it."
}

hgsea () {
    hg log | gg -C10 $@
}

hgtagb () {
    hg log --rev="branch(`hg branch`) and tag()" --template="{tags}\n"
}

what_is_repo_type () {
    if git branch >/dev/null 2>/dev/null; then echo -n git
    elif hg root >/dev/null 2>/dev/null; then echo -n mercurial
    elif svn info >/dev/null 2>/dev/null; then echo -n svn
    else echo -n 'unknown'
    fi
}

report_repo_type () {
    echo 'repository here ' `pwd` :
    bold_echo `what_is_repo_type`
}


inf () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) 
          local branch="${1:-$(bra)}"
          git describe --all; git branch -vv | grep "$branch"; git remote -v
          dat "$branch"
          ;;
      mercurial) hg id; hg paths
          ;;
      svn) svn info
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

log () {
    REPO=`what_is_repo_type`
    case "$REPO" in
        git) git log --decorate --graph --all --tags --name-status \
            --parents --abbrev-commit $@ | pp
            ;;
        mercurial) hg log -v $@ | pp
            ;;
        svn) svn log $@ | pp
            ;;
        *) red_echo unknown repository: $REPO
  esac
}
# fix autocompletion
[[ $CURSHELL == zsh ]] && compdef '_dispatch ls ls' log

# print graph for all branches
gra () {
    REPO=`what_is_repo_type`
    case "$REPO" in
        git) git log --oneline --tags --all --graph $@ | less -S
            ;;
        mercurial) hg log $@ | pp
            ;;
        svn) svn log $@ | pp
            ;;
        *) red_echo unknown repository: $REPO
  esac
}

# log with changes (-p)
lgf () {
    if [[ "$1" == "" ]]; then
        git log -p --parents $@ | less
    else
        git log -p --follow --parents $@ | less
    fi
}

# show log for specified branch
lgb () {
  REPO=`what_is_repo_type`
  local default=$(dbr)
  case "$REPO" in
      git) 
          if [ -z "$1" ] || [[ "$1" == "--" ]]; then
              branch=$(bra)
          else
              branch=$1
              shift 1
          fi
          if [[ "$branch" == "$default" ]]; then
              git log --decorate --graph --name-status \
              --parents --abbrev-commit $default $@ | pp
          else
              git log --decorate --graph --name-status \
              --parents --abbrev-commit $(git merge-base $branch $default)..$branch $@ | pp
          fi
          ;;
      mercurial) hg log -b `hg branch`
          ;;
      svn) svn log --use-merge-history --verbose $@ # TODO: URL required
          ;;
      *) red_echo unknown repository: $REPO

  esac
}

# show stashed changes
sho () {
    git stash show -p $@
}

# squash commits
squ () {
  local default=$(dbr)
  local branch=$(bra)
  git rebase -i $(git merge-base $branch $default)
}

# graph for feature branch
grb () {
  REPO=`what_is_repo_type`
  local default=$(dbr)
  case "$REPO" in
      git) 
          if [ -z "$1" ] || [[ "$1" == "--" ]]; then
              branch=$(bra)
          else
              branch=$1
              shift 1
          fi
          if [[ "$branch" == "$default" ]]; then
              git log --oneline --graph $default $@ | less -S
          else
              git log --oneline --graph \
                  $(git merge-base $branch $default)..$branch $@ | less -S
          fi
          ;;
      mercurial) hg log $@ | pp
          ;;
      svn) svn log $@ | pp
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

# show only branch log in git (approximately, using --first-parent)
gitlogb () {
    if [ "$1" -eq "" ]; then
        local branch="$(bra)"
    else
        local branch="$1"
    fi
    git log --decorate --graph --tags --name-status --first-parent "$branch" | p
}

gitgrb () {
    if [ "$1" -eq "" ]; then
        local branch="$(bra)"
    else
        local branch="$1"
    fi
    git log --decorate --graph --oneline --first-parent "$branch" | less -S
}

# `has revision branch` check that branch contains revision
function has {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git merge-base --is-ancestor $1 ${2:-$(bra)}
           if [ $? -eq 0 ]; then
              echo Yes
           else
              echo No
           fi
          ;;
      mercurial) hg log -r $1 -b $2
          ;;
      svn) echo not implemented for svn
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

cnt () {
    git rebase --continue
}

# history of all changes to file(s)
his () {
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

ann () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git blame --date=short $@ | less -S
          ;;
      mercurial) hg ann -b $@ | less -S
          ;;
      svn) svn ann $@ | less -S
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

# whether to print version info in PS1
wrepo="none"
wrepo () {
    if [ "$wrepo" = "none" ]; then
        wrepo="any"
    else
        wrepo="none"
    fi
}

bra () {
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

# list branches
lsb () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git branch
          ;;
      mercurial) hg branches --active
          ;;
      svn) svn info | grep '^URL:'
          ;;
      *) echo -n $REPO
  esac
}

# default branch
dbr () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
          ;;
      mercurial) echo default
          ;;
      svn) echo trunk
          ;;
      *) echo -n $REPO
  esac
}

# print the date of commit id $1
dat () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) 
          if [[ "$1" != "" ]]; then
              local id="$1"
          else
              local id="HEAD"
          fi
          git log -1 --format="%at" $id | xargs -I{} date -d @{} +%y-%b-%d\ %H:%M
          ;;
      mercurial) echo "d:hg"
          ;;
      svn) echo "d:svn"
          ;;
      *) echo -n $REPO
  esac
}

# print the date of commit id $1
datshort () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) 
          if [[ "$1" != "" ]]; then
              local id="$1"
          else
              local id="HEAD"
          fi
          git log -1 --format="%at" $id | xargs -I{} date -d @{} +%b%d
          ;;
      mercurial) echo "d:hg"
          ;;
      svn) echo "d:svn"
          ;;
      *) echo -n $REPO
  esac
}

# show files that are in repository
lsf () {
    git ls-files --error-unmatch $@
}

sta () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git status -s $@ | sed 's/\(.\{2\}\)./ \1 : /' | p
          ;;
      mercurial) hg status $@|p
          ;;
      svn) svn status $@|p
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

# colored diff
dif () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git)
          if [ ! -f $1 ]; then
              red_echo file $1 not found
          fi
          git diff -r HEAD -- $@|less
          ;;
      mercurial) hg diff $@|less
          ;;
      svn) svn diff $@|less
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

# diff for patch, uncolored, without pager
dfp () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git)
          if [ ! -f $1 ]; then
              red_echo file $1 not found
          fi
          git diff --color=never -r HEAD -- $@
          ;;
      mercurial) hg diff --color never $@
          ;;
      svn) svn diff $@
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

# VCS diff without colors (for patch)
difp () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git)
          if [ ! -f $1 ]; then
              red_echo file $1 not found
          fi
          git diff --color=never -r HEAD -- $@|less
          ;;
      mercurial) hg diff --color=never $@|less
          ;;
      svn) svn diff --color=never $@|less
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

# print file contents at given revision
pri () {
  local rev="$1"
  local file="$2"
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git show "$rev:$file" | less -X
          ;;
      mercurial) hg cat -r $rev "$file" | less -X
          ;;
      svn) svn cat -r $rev "$file" | less -X
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

# print history for given line: `lin <number> <file>`
lin () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git log -L $1,$1:"$2"
          ;;
      mercurial) red_echo not implemented
          ;;
      svn) red_echo not implemented
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

# show patch for a given revision
pat () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git show --parents $@ | less
          ;;
      mercurial) hg diff -c $@ | less
          ;;
      svn) svn diff -c $@ | less
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

# the same but with full files contents (1000 lines of context)
patf () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git show --parents -U1000 $@ | less -X
          ;;
      mercurial) hg diff -c $@ | less -X
          ;;
      svn) svn diff -c $@ | less -X
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

add () {
  for i in "$@"; do
    echo adding $i
    if [ -d "`dirname $i`" ]; then
        cd "`dirname $i`"
    else
        red_echo no such directory
        return 2
    fi
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
    local exit_code=$?
    cd -
    if [ $exit_code -ne 0 ]; then
        return $exit_code
    fi
  done
}

roo () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git rev-parse --show-toplevel
          ;;
      mercurial) hg root
          ;;
      *) red_echo unknown repository: $REPO
  esac
}
    
com () {
  REPO=`what_is_repo_type`
  local msg=""
  if [ "$1" != "" ]; then
      msg="-m \"$1\""
  fi
  case "$REPO" in
      git) #git add -u :/ && 
          eval git commit $msg && \
               mydialog "push?[n|y|f]" "n green_echo Done" \
               "y git push origin \"$(bra)\"" "f git push origin -f \"$(bra)\""
          ;;
      mercurial) eval hg commit $msg && (
          if grep default `hg root`/.hg/hgrc > /dev/null 2>&1; then
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

# save changes
sav () {
    git stash save $@
}

# restore changes
res () {
    git stash pop --index $@
}

pus () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git push origin "$(bra)" $@
          ;;
      mercurial) hg push $@
          ;;
      svn) svn commit $@
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

reb () {
    local def_br=$(dbr)
    local cur_br=$(bra)
    [[ $def_br = $cur_br ]] && red_echo On default branch && return 1
    git fetch origin "$def_br:$def_br" && git rebase "$def_br" && git push origin "$cur_br"
}

gitlfspur () {
    git lfs ls-files -n | xargs -d '\n' rm
    rvr "${1:-.}"
}

pur () {
  REPO=`what_is_repo_type`
  if [ -z $1 ]; then
      local arg=.
  else
      local arg="$1"
      shift 1
  fi
  local msg="purge $arg $@ ?[n|y]"

  case "$REPO" in
      git) mydialog $msg "n green_echo skipped" "y git clean  -d  -f -x $arg $@"
          # (-d untracked directories, -f untracked files, -x also ignored files)
          gitlfspur .
          ;;
      mercurial) mydialog $msg "n green_echo skipped" "y hg purge $arg $@"
          ;;
      svn) mydialog $msg "n green_echo skipped" "y svn cleanup --remove-unversioned $arg $@"
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

# uncommit latest commit
uncom () {
    git reset --soft HEAD~1
}

unstage () {
    if [ -f "$1" ]; then
        git reset HEAD "$1"
    fi
}

gitmerges () {
    git log $1.."`dbr`" --ancestry-path --merges | less +G
}

rvr () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git reset -- $@ # remove file from staging area
          git checkout -- $@
          #git reset --hard $@
          ;;
      mercurial) hg revert $@
          ;;
      svn) svn revert -R $@
          ;;
      *) red_echo unknown repository: $REPO
  esac
}

# undo add file
uad () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git reset -- $@
          ;;
      mercurial) hg revert $@
          ;;
      svn) svn revert -R $@
          ;;
  esac
}

export PREFERRED_REPO_TYPE=git

clo () {
  case "$PREFERRED_REPO_TYPE" in
      git) git clone --recursive $@
          ;;
      mercurial) hg clone $@
          ;;
      svn) svn clone $@
          ;;
  esac
}

# clone specific branch:
# clb <repo> <branch>
clb () {
  local repo=$1
  local branch=$2
  shift 2
  case "$PREFERRED_REPO_TYPE" in
      git) git clone --recursive -b $branch --single-branch $repo $@
          ;;
      mercurial) hg clone $repo -b $branch $@
          ;;
      svn) svn clone $repo/branches/$branch $@
          ;;
  esac
}

# download & update
pul () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git pull --recurse-submodules origin "$(bra)"
          local exit_code=$?
          [ $exit_code -ne 0 ] && return $exit_code
          git submodule update
          if exist git-lfs; then
              mydialog "Pull git lfs? [n|y]" "n green_echo skipped" "y git lfs pull"
          fi
          ;;
      mercurial) hg pull -u $@
          ;;
      svn) svn up $@
          ;;
  esac
}

# get #download remote changes
# get branch #download remote changes from branch
get () {
  REPO=`what_is_repo_type`
  local default=$(dbr)
  case "$REPO" in
      git) 
          if [[ "$1" != "" ]]; then
              local branch="$1"
              echo git fetch --recurse-submodules origin $branch:$branch
              git fetch --recurse-submodules origin $branch:$branch
          else
              local branch="$(bra)"
              echo git fetch --recurse-submodules origin $branch
              git fetch --recurse-submodules origin $branch
              # try fetching also default branch (master)
              if [[ "$branch" != "$default" ]]; then
                  echo git fetch --recurse-submodules origin $default:$default
                  git fetch --recurse-submodules origin $default:$default
              fi
          fi
          ;;
      mercurial) hg pull $@
          ;;
      svn) echo not applicable
          ;;
  esac
}

upd () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git merge
          if exist git-lfs; then
              git lfs pull
          fi
          ;;
      mercurial) hg co $@
          ;;
      svn) svn up $@
          ;;
  esac
}

# list branches
lbr () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git)
          git for-each-ref --sort=committerdate refs/heads/ \
              --format='%(committerdate:short): %(refname:short)' | pb
          ;;
      mercurial) red_echo not implemented
          ;;
      svn) red_echo not implemented
          ;;
  esac
}

# checkout specified revision
cou () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git checkout $@
          ;;
      mercurial) hg co $@
          ;;
      svn) svn up $@
          ;;
  esac
}

# restore master to origin/master
upd_master () {
    git checkout -B master origin/master
}

mov () {
  REPO=`what_is_repo_type`
  case "$REPO" in
      git) git mv $@
          ;;
      mercurial) hg mv $@
          ;;
      svn) svn mv $@
          ;;
  esac
}

# show pushd stack
alias d="dirs -v"

ts () {
    date -R -r $@
}

mysetfont () {
    if exist xtermcontrol; then
        TERM=xterm xtermcontrol --font="xft:Ubuntu Mono:pixelsize=$1"
    else # try for urxvt
        echo "]50;xft:Ubuntu Mono:pixelsize=$1"; echo $1;
    fi
}

for i in `seq 0 99`; do alias ff$i="mysetfont $i"; done


##############################################################################
# misc functions
# http://www.gentoo.org/doc/en/portage-utils.xml

pkg () {
  local SYSDIST="`os_distribution`"
  if [ "$SYSDIST" = "unknown" ]; then
      red_echo unknown distribution
      return
  fi
  if [[ "$1" == "help" || "$1" == "-h" || "$1" ==  "--help" ||
        "$1" == "-help" ]]; then
      echo -e " s"\|"se"\|"search"\\tsearch package name \\n\
          "i"\\t\\tinstall package \\n\
          "info"\\t\\tinformation about package \\n\
          "rm"\\t\\tremove package \\n\
          "grep"\\tlist installed packages \\n\
          "files"\|"ls"\|"list"\\t\\tlist files owned by package \\n\
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
              "owns"|"which"|"own") rpm -qf "$2" ;;
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
              "grep") dpkg -l $2 ;;
              "files"|"ls"|"list") dpkg -L "$2" ;;
              "owns"|"which"|"own") dpkg -S "$2" ;;
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
              "owns"|"which"|"own") qfile "$2" ;;
              *) red_echo unknown command "$1"
          esac
          ;;
      *)  red_echo unknown distribution
          return
  esac
}

eline () {
  while read str; do $@ "$str"; done
}

empty () {
    while true; do echo -n y; sleep 5; done;
}
clock () {
    clear
    while :
    do
        ti=`date +"%r"`
        # save current screen position & attributes
        echo -e -n "\033[7s"
        # row 0 and column 69 is used to show clock
        tput cup 0 69
        # put clock on screen
        echo -n $ti
        # restore current screen position & attributs
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

my () {
  local FILE="$1"
  local DIR=`dirname "$FILE"`
  local BASE=`basename "$FILE"`
  local EXT=`ext "$FILE"`
  local BAS=`basename "$BASE" .$EXT`
  case "$EXT" in
      "tex")
          cd $DIR
          pdflatex "$BASE" && pdflatex "$BASE" && o "$BAS.pdf"&
          cd -
          ;;
      "nim")
          nim c -r "$FILE"
          ;;
      *)
          red_echo unknown file extension: $EXT
  esac
}

##############################################################################
# [Section initial screen]
##############################################################################

if false && exist /usr/lib/w3m/w3mimgdisplay && \
   [ -d ~/activity-personal/computer-program-data/pictures ] && \
   [[ "$DISPLAY" != "" ]] ; then
    clear
    dfile=`shuf -n1 -e ~/activity-personal/computer-program-data/pictures/*`
    w3disp.sh $dfile
fi

if exist fortune; then
    fortune ru 2> /dev/null
    echo
    fortune 2> /dev/null
fi

# to disable sw flow control (ctrl-s, ctrl-q)
#stty stop undef
#stty start undef

##############################################################################
# local.sh can overwite above settings
if [ -f  ~/local-adjust.sh ] ; then
    echo Load local-adjust.sh
    . ~/local-adjust.sh
fi

if [[ $CURSHELL == zsh ]]; then
    local file=~/activity-public/computer-program-data/development/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    if [ -f $file ]; then
        source $file
    fi
fi
