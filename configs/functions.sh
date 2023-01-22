#!/usr/bin/env bash

# reset terminal with disabling ctrl-s/ctrl-q
re () {
    reset
    stty stop undef
    stty start undef
}

is_number () {
    case "$1" in
        ''|*[!0-9]*) return 1 ;;
        *) return 0  ;;
    esac
}

# Variables for terminal requests.
[[ -t 2 ]] && { 
    alt=$(      tput smcup  || tput ti      ) # Start alt display
    ealt=$(     tput rmcup  || tput te      ) # End   alt display
    hide=$(     tput civis  || tput vi      ) # Hide cursor
    show=$(     tput cnorm  || tput ve      ) # Show cursor
    save=$(     tput sc                     ) # Save cursor
    load=$(     tput rc                     ) # Load cursor
    bold=$(     tput bold   || tput md      ) # Start bold
    stout=$(    tput smso   || tput so      ) # Start stand-out
    estout=$(   tput rmso   || tput se      ) # End stand-out
    under=$(    tput smul   || tput us      ) # Start underline
    eunder=$(   tput rmul   || tput ue      ) # End   underline
    reset=$(    tput sgr0   || tput me      ) # Reset cursor
    blink=$(    tput blink  || tput mb      ) # Start blinking
    italic=$(   tput sitm   || tput ZH      ) # Start italic
    eitalic=$(  tput ritm   || tput ZR      ) # End   italic
[[ $TERM != *-m ]] && { 
    red=$(      tput setaf 1|| tput AF 1    )
    green=$(    tput setaf 2|| tput AF 2    )
    yellow=$(   tput setaf 3|| tput AF 3    )
    blue=$(     tput setaf 4|| tput AF 4    )
    magenta=$(  tput setaf 5|| tput AF 5    )
    cyan=$(     tput setaf 6|| tput AF 6    )
}
    white=$(    tput setaf 7|| tput AF 7    )
    default=$(  tput op                     )
    normal=$(	tput sgr0                   )
    eed=$(      tput ed     || tput cd      )   # Erase to end of display
    eel=$(      tput el     || tput ce      )   # Erase to end of line
    ebl=$(      tput el1    || tput cb      )   # Erase to beginning of line
    ewl=$eel$ebl                                # Erase whole line
    #draw=$(     tput -S <<< '   enacs
    #                            smacs
    #                            acsc
    #                            rmacs' || { \
    #            tput eA; tput as;
    #            tput ac; tput ae;         } )   # Drawing characters
    back=$'\b'
} 2>/dev/null ||:

myecho () {
    echo -ne "$1" 1>&2
    shift 1
    # double [[ ]] are essential
    if [[ "$@" != "" ]]; then
        echo -ne "$@" 1>&2
        echo -e "\033[0m" 1>&2
    else
        echo -ne "\033[0m" 1>&2
    fi
}

#1.for error indication
red_echo () {
    myecho $red $@
}

#2.for success indication
green_echo () {
    myecho $green $@
}

#3. for warnings
yellow_echo () {
    myecho $yellow $@
}

#4. for questions
blue_echo () {
    myecho $blue $@
}

#5. for important messages
bold_echo () {
    myecho $bold $@
}

fill_echo () {
    local color="$1"
    shift 1
    local msg="$*"
    local cols=${COLUMNS:-$(tput cols)}
    let "lines=(${#msg}-1)/$cols+1"
    let "fillsize=$lines*$cols-${#msg}"
    echo -ne $color 1>&2
    printf '%s%*s\n' "$msg" $fillsize 1>&2
    echo -ne "\033[0m" 1>&2
}

#6. for warnings (yellow echo)
warning_echo () {
    fill_echo $yellow$stout "$@"
}

error_echo () {
    fill_echo $red$stout "$@"
}

#6. for messages about danger (bold red echo)
alert_echo () {
    fill_echo $bold$red$stout "$@"
}

#7. auxillary info in cyan
aux_echo () {
    myecho $cyan $@
}

#
red_command () {
  $@
  local code="$?"
  if [ "$code" != 0 ]; then
      alert_echo command "$@" exited abnormally, exit code = $code
      exit $code
  fi
}

isok () {
  local code="$?"
  if [ "$code" != 0 ]; then
      alert_echo command exited abnormally, exit code = $code
  fi
}

# check exit code after previous command
control () {
  local code="$?"
  if [ "$code" = "0" ]; then
      green_echo $1
  else
      alert_echo $2 "(exit code = $code)"
  fi
  return $code
}

decolorize () {
    perl -pe 's/\e([^\[\]]|\[.*?[a-zA-Z]|\].*?\a)//g'
}

addmanpath () {
    export MANPATH=$1:$MANPATH 
}
add1path () {
    export PATH=$1:$PATH 
}
add2path () { 
    export PATH=$PATH:$1 
}
add1ldlib () { 
    export LD_LIBRARY_PATH=$1:$LD_LIBRARY_PATH 
}
add2ldlib () { 
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$1 
}

ext () {
    local filename=$(basename "$1")
    echo "${filename##*.}"
}

exist () {
    command which $@ > /dev/null 2>&1
}

getch () {
    OLD_STTY=`stty -g`
    stty cbreak -echo
    read -n 1 GETCH
    stty $OLD_STTY
}

split1 () {
    local first=true
    local  __resultvar1=$2
    local  __resultvar2=$3
    local listtail=""
    for i in `echo $1`; do
        if $first; then
            eval $__resultvar1="'$i'"
            first=false
        else
            listtail="$listtail $i"
        fi
        eval $__resultvar2="'$listtail'"
    done
}

mydialog () {
  if [[ "$1" == "-alert" ]]; then
      alert_echo $2
      shift 2
  elif [[ "$1" == "-warning" ]]; then
      warning_echo $2
      shift 2
  else
      bold_echo $1
      shift 1
  fi

  local variant
  local tag
  local command
  read variant
  # 1st variant is default
  if [ "$variant" = "" ]; then
      split1 "$1" tag command
      eval $command
      return $?
  fi
  while (( $# )); do
      split1 "$1" tag command
      if [[ "$variant" == "$tag" ]]; then
          eval $command
          return $?
      fi
      shift 1
  done
  red_echo unknown answer: "$variant"
}

myread () {
  if [[ "$1" == "-alert" ]]; then
      alert_echo $2 \(default $3\)
      shift 2
  elif [[ "$1" == "-warning" ]]; then
      warning_echo $2 \(default $3\)
      shift 2
  else
      bold_echo $1 \(default $2\)
      shift 1
  fi

  local variant
  read variant
  # 1st variant is default
  if [ "$variant" = "" ]; then
      echo $1
  else
      echo "$variant"
  fi
}

fmount () {
    if [ "$1" = "-h" ]; then
        echo usage:
        echo $0 "host [directory_to_mount] [port]"
        return 0
    fi
    local dir="$2"
    local port="$3"
    if [ "$dir" = "" ]; then
        echo mount /home/username by default
    fi
    if [ "$port" = "" ]; then
        port="22"
    fi
    MNTPOINT=~/mnt/$1
    mkdir -p $MNTPOINT
    local CMD="sshfs -o reconnect -C -o workaround=all -p $port $1:$dir $MNTPOINT"
    echo $CMD
    eval "$CMD"
    control "mounted on $MNTPOINT" "error mounting $MNTPOINT"
}

fumount () {
    local MNTPOINT
    if [ "$1" != "" ]; then
        MNTPOINT=~/mnt/$1
        bold_echo umounting $MNTPOINT
        fusermount -u $MNTPOINT
        control "umount $MNTPOINT succeed" "umount $MNTPOINT failed"
        return $?
    else
        bold_echo umounting all ssh-filesystems
        if exist findmnt; then
            for MNTPOINT in `findmnt -t fuse.sshfs | grep fuse.sshfs | cut -d" " -f 1`; do
                bold_echo umounting $MNTPOINT
                fusermount -u "$MNTPOINT"
                control "umount $MNTPOINT succeed" "umount $MNTPOINT failed"
                return $?
            done
        else
            for MNTPOINT in `mount -t fuse.sshfs | grep -i "user=$USER" | cut -d" " -f 3`; do
                bold_echo umounting $MNTPOINT
                fusermount -u "$MNTPOINT"
                control "umount $MNTPOINT succeed" "umount $MNTPOINT failed"
                return $?
            done
        fi
    fi
}

mnt () {
  if [ "$1" = "" ]; then
  echo ---labels--------------------------------------------------------------
  ls -l /dev/disk/by-label
  echo ---UUIDs---------------------------------------------------------------
  ls /dev/disk/by-uuid/
  echo -----------------------------------------------------------------------
  else
      local mntpath=""
      if [ -e /dev/disk/by-label/$1 ]; then
          mntpath=/dev/disk/by-label/$1
      elif [ -e /dev/disk/by-uuid/$1 ]; then
          mntpath=/dev/disk/by-uuid/$1
      elif [ -e /dev/$1 ]; then
          mntpath=/dev/$1
      else
          alert_echo not found in /dev/disk/by-label/,/dev/disk/by-uuid/,/dev/
          return 1
      fi
      if exist udisksctl; then
          for i in $@ ; do
              udisksctl mount -b $mntpath
          done
      elif exist udisks; then
          for i in $@ ; do
              udisks --mount $mntpath
          done
      else
          alert_echo udisks commands not found
      fi
  fi
}

os_distribution () {
  if [ -f /etc/os-release ]; then
      cat /etc/os-release |grep \^ID=|cut -c 4-
  else
      local SYSDIST=""
      if [ -f /etc/redhat-release ]; then
          SYSDIST="redhat"
      elif [ -f /etc/gentoo-release ]; then
          SYSDIST="gentoo"
      else
          SYSDIST="unknown"
      fi
      echo $SYSDIST
  fi
}

myextdrive () {
  if [[ `os_distribution` = "ubuntu" || `os_distribution` = "debian" ]]; then
      echo /media/$USER
  elif [[ `os_distribution` = "arch" ]]; then
      echo /run/media/$USER
  else
      echo /media
  fi
}

showalias () {
  if alias $1 >/dev/null; then
      alias $1 | cut -d = -f 2- | tr -d \'
  else
      echo $1
  fi
}

uncomment () {
  local pattern="$1"
  local file="$2"
  awk -i inplace "BEGIN{IGNORECASE=1} /#*$pattern*/ { sub (\"^ *#\",\"\") } { print }" $file
}

cle() {
    echo 3 > /sys/class/graphics/fbcon/rotate_all
}

cri() {
    echo 1 > /sys/class/graphics/fbcon/rotate_all
}

cno() {
    echo 0 > /sys/class/graphics/fbcon/rotate_all
}
