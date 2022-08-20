
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
if [ -z "$HOSTNAME" ]; then  # for Zsh
    export HOSTNAME=$HOST
fi
if [ -f ~/local.init.sh ] ; then
    . ~/local.init.sh
fi

[ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH2_CLIENT" ] \
    && inside_ssh=true
[ -n "$VNCDESKTOP" ] && inside_vnc=true

# Note $SHELL env. variable can be wrong
CURSHELL=`ps -p $$ | tail -1 | awk '{print $NF}'`
CURSHELL=${CURSHELL##*/}  # basename
CURSHELL=${CURSHELL##*-}  # drop first - in -zsh on MacOS

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

if [ -z "$DISPLAY" ]; then
    setfont FullCyrAsia-Terminus32x16
fi

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
for term in qterminal konsole urxvt gnome-terminal xterm roxterm rxvt-unicode xfce4-terminal ; do
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

# compile nim compiler (with debugging) as `nimdbg` (FAST way)
mknimdbg () {
    local dir="$HOME/share/activity-public/Nim"
    nim c --lib:lib --debuginfo --lineDir:on -o:"$dir"/bin/nimdbg "$dir"/compiler/nim.nim
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
  env ALLOW_BASH=true bash $@
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
    if [[ -f ~/.ssh/myagent.sh ]]; then
        . ~/.ssh/myagent.sh
    fi
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
    # adding + 0 to force numeric comparison
    netstat -lnt | awk '
    sub(/.*:/,"",$4) && ($4 + 0) >= 6000 && ($4 + 0) < 6100 {
    print ($1 == "tcp6" ? "ip6-localhost:" : "localhost:") ($4 - 6000)
    }'
    echo
}

set_display () {
    if [ $inside_ssh ]; then
        show_displays
        bold_echo Input display or press enter \[default: `cat ~/.display-x11-$HOSTNAME`\]
        local line
        read line
        x $line
    elif [ ! -z "$DISPLAY" ]; then
        x $DISPLAY
    else
        bold_echo no X11 display was determined
    fi
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
       f - Screen force attach to work session;
       t - Screen atttach any session;
       q - exit" \
           "h exec screen -S aux" \
           "s echo Just shell" \
           "b exec bash" \
           "w SCREEN_WORK_SESSION=true exec screen -S work" \
           "W screen_try_attach work" \
           "f screen -dr -S work" \
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

#if [ $inside_ssh ] && [ ! $inside_vnc ] && [ -z $ALLOW_BASH ]; then
if [ -z $ALLOW_BASH ]; then
    #tmux_try_start
    screen_try_start
fi
##############################################################################
# definitions for interactive work only

# tt: set Tab Title (and optionally Tab number)
# rename current tmux window and move it to the specified number
# tt _ 7     # move window to 7
# tt Name 7  # move window to 7 and rename to "Name"
tt () {
force_window_name=$1
case "$TERM" in
  screen|screen.*)
      if [ ! -z "$2" ]; then
          screen -X number "$2"
      fi
      echo -ne "\ek${1}\e\\"
      ;;
  *)
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
esac
}

# tn: set Tab Number
tn () {
case "$TERM" in
  screen|screen.*)
      screen -X number "$1"
      ;;
  *)
      tmux swap-window -t "$1"
esac
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
vr () {
    # Add $(roo)/ before all arguments in $@
    vim -p "${@/#/$(roo)/}"
}

# show my shortcuts
k () {
    vim ~/activity-public/computer-program-data/configs/shortcuts.txt
}

T () {
    vim -c "set title" -c "set titlestring=TASK" ~/tips/
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
r () {
    ranger --choosedir=$HOME/.config/ranger/lastdir
    cd "`cat $HOME/.config/ranger/lastdir`"
}

# show only my processes, full format
psu () {
    ps -f --forest -u ${1:-$USER} | less
}

# show all processes, short format
psa () {
    ps -A o user,pid,comm --forest | less
}

users () {
    who -u | grep `$DATE_COMMAND +'%Y-%m-%d'` |  sort -n -k 5
}
psc () {
    ps -f --forest | less
}

# show file system hierarchy
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
    xdg-open $@
    #if exist mimeopen; then
    #    mimeopen $@
    #elif exist xdg-open; then
    #    xdg-open $@
    #else
    #    red_echo neither mimeopen nor xdg-open exists
    #fi
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

# pager for graphical info (like git log --graph): preserving long lines
pg () {
    # -S means don't wrap lines
    less -X -F -S
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

nn () {
  local n=$1
  echo "$(cat ~/tmp/buffer|decolorize|head -n $n|tail -n 1|trim_spaces)"
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
        #echo running:
        bold_echo $cmd \"$line_proc\"
    fi
    add_command $cmd \"$line_proc\"
    eval $cmd \"$line_proc\"
  fi
}

#open file +line in vim
vv () {
    if [[ "$1" == "" ]]; then
        local n=1
    else
        local n=$1
    fi
    filter="$2"
    local line="$(cat ~/tmp/buffer|decolorize|head -n $n|tail -n 1)"
    #echo \ \ line:	$line
    local line_proc
    if [[ "$filter" == "" ]]; then
        line_proc="$line"
    else
        line_proc="`echo $line | eval $filter`"
    fi
    # /bin/echo is used since zsh echo interprets escapes like '\n' by default
    local fname="$(/bin/echo $line_proc | cut -f1 -d: | trim_spaces)"
    local lineNo="$(/bin/echo $line_proc: | cut -f2 -d: | trim_spaces)"
    #echo \ \ fname:	$fname
    #echo \ \ lineN:	$lineNo
    if [[ "$lineNo" == "" ]]; then
        bold_echo vim \'$fname\'
        add_command vim \'$fname\'
        eval vim \'$fname\'
    elif is_number "$lineNo"; then
        bold_echo vim \'$fname\' +$lineNo
        add_command vim \'$fname\' +$lineNo
        eval vim \'$fname\' +$lineNo
    else
        bold_echo vim -p \'$fname\' \'$lineNo\'
        aux_command vim -p \'$fname\' \'$lineNo\'
        eval vim -p \'$fname\' \'$lineNo\'
    fi
}

trim_spaces () {
    sed "s/^[ \t]*//;s/[ \t]*$//" $@
}

# aliases named b1, b2, ..., b999 to process string as an argument of a
# command:
# > b111 command
#just print line:
for i in `seq 1 999`; do alias n$i="nn $i ''"; done
#process all line
for i in `seq 1 999`; do alias b$i="bb $i ''"; done
for i in `seq 1 999`; do alias o$i="bb $i '' o"; done
#process first field, e.g. 'x' in 'x:y'
for i in `seq 1 999`; do alias b${i}p="bb $i 'cut -f1  -d: | trim_spaces'"; done
for i in `seq 1 999`; do alias b${i}n="bb $i 'cut -f2- -d: | trim_spaces'"; done
# for git output
for i in `seq 1 999`; do alias b${i}d="bb $i 'cut -f2- -d: | trim_spaces' dif"; done
for i in `seq 1 999`; do alias b${i}a="bb $i 'cut -f2- -d: | trim_spaces' git add -p"; done
#alias to open file +line in vim
for i in `seq 1 999`; do alias v$i="vv $i"; done
for i in `seq 1 999`; do alias v${i}p="vv $i 'cut -f1  -d: | trim_spaces'"; done
for i in `seq 1 999`; do alias v${i}n="vv $i 'cut -f2- -d: | trim_spaces'"; done

nd () {
    mkdir -p "$1" && cd "$1"
}

loc () {
    locate $@ | pb
}

l () {
    cd "$1" && ls -C -w "$COLUMNS" | less -F
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

# print history commands with relative numbers like -1, -2, etc
h () {
    local first=${1-30}
    local shiftval=0
    [[ $CURSHELL == zsh ]] && shiftval=1
    fc -l -$first | awk "{printf(\"%3s \", \$1-$HISTCMD-$shiftval);
                         \$1=\"\"; print \$0}" | less -E -X
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

# use mm (my man) instead of `man` 
# (because defining `man` makes zsh autocompletion hang)
mm () {
    local vim_variant=vim
    # if exist nvim; then
    #     vim_variant=nvim
    # fi
    # Note that "Man $@" would behave incorrectly,
    # it would expand to "'Man $1' '$2' ..."
    $vim_variant -c 'runtime ftplugin/man.vim' \
        -c 'map q :q<CR>' \
        -c 'set nolist' \
        -c "Man $*" -c 'wincmd o'
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
    local pat=$1
    if [ $# -gt 1 ]; then
        shift 1
        echo find $@ -iwholename "*$pat*"
        find $@ -iwholename "*$pat*" | p
    else
        echo find . -iwholename "*$pat*"
        find . -iwholename "*$pat*" | p
    fi
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
    python3 -m py_compile $@
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

if [[ "$OSTYPE" != "linux-gnu" ]] && exist gdate; then
    # assuming GNU coreutils installed in FreeBSD or MacOS
    DATE_COMMAND=gdate
else
    DATE_COMMAND=date
fi

curtime () {
    $DATE_COMMAND +%s.%N
}

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
  local input=$1
  local file=${2:-`mktemp`.pdf}
  echo "output will be to $file"
  local numOdd
  echo "Number odd [cm]? (default: 1.0 cm) "
  read numOdd
  if [ -z "$numOdd" ]; then
      numOdd=1.0
  fi
  echo "shifting odd = $numOdd cm"

  pdfjam --twoside --offset "${numOdd}cm 0cm 0cm 0cm" "$input" -o "$file"
  o "$file"
  [ -z "$2" ] && rm "$file" || echo Output to file $2
}

# Crow leaving only these margins for twoside printing
twosidecrop () {
    pdfcrop3.sh -two -m "50 20 20 20" "$1" "$2"
}

twoside2 () {
  local input=$1
  local file=${2:-`mktemp`.pdf}
  echo "output will be to $file"
  local numOdd
  local numEven
  echo "Number odd [pt]? (default: 30pt = 1.06cm) "
  read numOdd
  if [ -z "$numOdd" ]; then
      numOdd=30
  fi
  echo "Number even [pt]? (default: -30pt = -1.06cm) "
  read numEven
  if [ -z "$numEven" ]; then
      numEven=-30
  fi
  echo "shifting odd = $((numOdd*0.0353)) cm  even = $((numEven*0.0353)) cm"
  # 40 pts means ~ 1.41cm
  gs -q -sDEVICE=pdfwrite -dBATCH -dNOPAUSE -sOutputFile="$file" \
  -dDEVICEWIDTHPOINTS=623 -dDEVICEHEIGHTPOINTS=842 -dFIXEDMEDIA \
  -c "<< /CurrPageNum 1 def /Install { /CurrPageNum CurrPageNum 1 add def
   CurrPageNum 2 mod 1 eq {$numOdd 0 translate} {$numEven 0 translate} ifelse } bind  >> setpagedevice" \
  -f "$input"

  o "$file"
  [ -z "$2" ] && rm "$file" || echo Output to file $2
}

pdfmargins () {
  local input=$1
  local file=${2:-`mktemp`.pdf}
  echo "output will be to $file"
  local numLeft
  local numRight
  echo "Number left [pt]? (default: -40pt = -1.06cm) "
  read numLeft
  if [ -z "$numLeft" ]; then
      numLeft=-40
  fi
  echo "Number right [pt]? (default: -40pt = -1.06cm) "
  read numRight
  if [ -z "$numRight" ]; then
      numRight=-40
  fi
  echo "margins right = $((numLeft*0.0353)) cm  right = $((numRight*0.0353)) cm"
  # 40 pts means ~ 1.41cm
  pdf-crop-margins -a4 $numLeft 0 $numRight 0 "$input" -o "$file"

   o "$file"
   [ -z "$2" ] && rm "$file" || echo Output to file $2
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
export PATH=$HOME/bin:$HOME/activity-personal/computer-program-data/bin:$HOME/opt/bin:$HOME/.local/bin:/usr/local/bin:$PATH:/usr/local/games:/usr/games:/opt/bin

. ~/.functions_vcs.sh

# show pushd stack
alias d="dirs -v"

ts () {
    $DATE_COMMAND -R -r $@
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
      echo -e " s"\|"se"\|"search"\\tsearch any package name in repo\\n\
          "grep"\|"list"\\tsearch installed packages \\n\
          "i"\\t\\tinstall package \\n\
          "info"\\t\\tinformation about package \\n\
          "rm"\\t\\tremove package \\n\
          "files"\|"ls"\\tlist files owned by package \\n\
          "owns"\\t\\twhich "  "installed package owns this file\? \\n\
          "where"\\t\\twhich uninstalled package owns this file\? \\n\
          "help|h"\\t\\tthis help
      return
  fi
  case "$SYSDIST" in
      "redhat")
          case "$1" in
              "s"|"se"|"search") yum search "$2" ;;
              "i") yum install "$2" ;;
              "info") yum info "$2" ;;
              "rm") yum remove "$2" ;;
              "grep"|"list") rpm -qa "$2";;
              "files"|"ls") rpm -ql "$2" ;;
              "owns"|"own") rpm -qf "$2" ;;
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
              "grep"|"list") dpkg -l "*$2*" ;;
              "files"|"ls") dpkg -L "$2" ;;
              "owns"|"own") dpkg -S "$2" ;;
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
              "grep"|"list") equery list '*' ;; #not tested
              "files"|"ls") qlist "$2" ;;
              "owns"|"own") qfile "$2" ;;
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
        ti=`$DATE_COMMAND +"%r"`
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
export TEXINPUTS=$HOME/activity-personal/computer-program-data/latex:

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
