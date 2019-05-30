#!/usr/bin/env bash
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
    draw=$(     tput -S <<< '   enacs
                                smacs
                                acsc
                                rmacs' || { \
                tput eA; tput as;
                tput ac; tput ae;         } )   # Drawing characters
    back=$'\b'
} 2>/dev/null ||:

function myecho {
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
function red_echo {
myecho $red $@
}

#2.for success indication
function green_echo {
myecho $green $@
}

#3. for warnings
function yellow_echo {
myecho $yellow $@
}

#4. for questions
function blue_echo {
myecho $blue $@
}

#5. for important messages
function bold_echo {
myecho $bold $@
}

function fill_echo {
local color="$1"
shift 1
local msg="$*"
local cols=${COLUMNS:-$(tput cols)}
if [ ${#msg} -gt 0 ]; then
    let "lines=(${#msg}-1)/$cols+1"
    let "fillsize=$lines*$cols-${#msg}"
    echo -ne $color 1>&2
    printf '%s%*s\n' "$msg" $fillsize 1>&2
    echo -ne "\033[0m" 1>&2
fi
}

#6. for warnings (yellow echo)
function warning_echo {
fill_echo $yellow$stout "$@"
}

function error_echo {
fill_echo $red$stout "$@"
}

#6. for messages about danger (bold red echo)
function alert_echo {
fill_echo $bold$red$stout "$@"
}

#7. auxillary info in cyan
function aux_echo {
myecho $cyan $@
}

#
function red_command {
  $@
  local code="$?"
  if [ "$code" != 0 ]; then
      alert_echo command "$@" exited abnormally, exit code = $code
      exit $code
  fi
}

function isok {
  local code="$?"
  if [ "$code" != 0 ]; then
      alert_echo command exited abnormally, exit code = $code
  fi
}

function control {
  local code="$?"
  if [ "$code" = "0" ]; then
      green_echo $1
  else
      alert_echo $2 "(exit code = $code)"
  fi
  return $code
}

function decolorize {
perl -pe 's/\e([^\[\]]|\[.*?[a-zA-Z]|\].*?\a)//g'
}

function addmanpath {
export MANPATH=$1:$MANPATH 
}
function add1path {
export PATH=$1:$PATH 
}
function add2path { 
export PATH=$PATH:$1 
}
function add1ldlib { 
export LD_LIBRARY_PATH=$1:$LD_LIBRARY_PATH 
}
function add2ldlib { 
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$1 
}

function ext {
local filename=$(basename "$1")
echo "${filename##*.}"
}

function exist {
if which $@ &> /dev/null; then true; else false; fi
}

getch () {
	OLD_STTY=`stty -g`
	stty cbreak -echo
	read -n 1 GETCH
	stty $OLD_STTY
}

function split1 {
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

function mydialog {
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
      return
  fi
  while (( $# )); do
	  split1 "$1" tag command
	  if [[ "$variant" == "$tag" ]]; then
	      eval $command
	      return
	  fi
	  shift 1
  done
  red_echo unknown answer: "$variant"
}

function myread {
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

function fmount {
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

function fumount {
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

function mnt {
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

function os_distribution {
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

function myextdrive {
  if [[ `os_distribution` = "ubuntu" || `os_distribution` = "debian" ]]; then
      echo /media/$USER
  elif [[ `os_distribution` = "arch" ]]; then
      echo /run/media/$USER
      #echo /media
  else
      echo /media
  fi
}

function showalias {
  if alias $1 >/dev/null; then
      alias $1 | cut -d = -f 2- | tr -d \'
  else
      echo $1
  fi
}

function uncomment {
  local pattern="$1"
  local file="$2"
  awk -i inplace "BEGIN{IGNORECASE=1} /#*$pattern*/ { sub (\"^ *#\",\"\") } { print }" $file
}
