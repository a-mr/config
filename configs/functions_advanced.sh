
difftree () {
    colordiff <(cd "$1"; find .|sort) <(cd "$2"; find .|sort)|p
}


local FIRST_HISTCMD=0

# print something before command next command prompt
print_precmd () {
    local RESULT=$?
    local finish_time="`curtime`"
    local exe_time
    if [[ $CURSHELL == zsh ]]; then
        exe_time=$((finish_time-start_time))
    else
        exe_time=`awk "BEGIN { print $finish_time-$start_time }"`
    fi
    local curdir=`dirs -p | head -n1`
    local info=$(printf "%s(%.2f)" "$(date +%H:%M:%S)" "$exe_time")
    info+=" $curdir"
    #show repository branch if requested
    if [ "$wrepo" != "none" ]; then
        info+=" '$(bra) $(datshort)'"
    fi
    if (( $RESULT == 0 )); then
        fill_echo $stout$cyan " $info"
    # not found or SIGPIPE received
    elif  (( $RESULT == 127 || $RESULT == 141 )); then
        warning_echo "exit=$RESULT; $info"
    else
        error_echo "exit=$RESULT; $info"
    fi
    local name=$force_window_name
    if [ -z "$name" ]; then
        name="${PWD##*/}"  # get last part of the path
    fi
    # set the titles to last path component of working directory
    case "$TERM" in
      screen|screen.*)
        # set screen title
        echo -ne "\ek${name}\e\\"
        # must (re)set xterm title
        echo -ne "\e]0;${name}\a"
        #alarm
        echo -ne \\a
        ;;
      rxvt|rxvt-256color|rxvt-unicode|xterm|xterm-color|xterm-256color)
        echo -ne "\e]0;${name}\a"
        ;;
    esac
}

# print before command execution
print_preexec () {
    start_time="`curtime`"

    case "$TERM" in
      screen|screen.*)
        export DISPLAY=`cat $HOME/.display-x11-$HOSTNAME`
        local a=""
        if [[ $CURSHELL == bash ]]; then
          a="$1"
          a="${a%% *}"      # get the command
          a="${a##*\/}"     # get the command basename
        elif [[ $CURSHELL == zsh ]]; then
          a=${${1## *}[(w)1]}  # get the command
          local b=${a##*\/}   # get the command basename
          #echo b: $b
          #a="${b}${1#$a}"     # add back the parameters
          a=${a//\%/\%\%}     # escape print specials
          a=$(print -Pn "$a" | tr -d "\t\n\v\f\r")  # remove fancy whitespace
          a=${(V)a//\%/\%\%}  # escape non-visibles and print specials
        fi
        # See screen(1) "TITLES (naming windows)".
        # "\ek" and "\e\" are the delimiters for screen(1) window titles
        # set screen title
        echo -ne "\ek$a\e\\"
        # must (re)set xterm title
        echo -ne "\e]0;${PWD##*/}> $1\a"
        ;;
      rxvt|rxvt-256color|rxvt-unicode|xterm|xterm-color|xterm-256color)
        echo -ne "\e]0;${PWD##*/}> $1\a"
        ;;
    esac
}

##############################################################################
# shell-specific settings - for bash or zsh

if [[ $CURSHELL == zsh ]]; then
    echo "zsh detected"
    # in pipes: use the exit code of last program to exit non-zero
    [[ $ZSH_VERSION > 5 ]] && set -o pipefail
    HISTFILE=~/.histfile
    #almost infinite history for zsh = LONG_MAX
    SAVEHIST=2147483647
    HISTSIZE=$SAVEHIST
    setopt EXTENDED_HISTORY
    bindkey -v
    help ()
    {
        command man zshbuiltins | less -p "^       $1 "
    }
    # create some widgets
    zle -N next-history
    zle -N previous-history
    zle -N re-read-init-file
    # backspace in vim's style instead of vi
    bindkey "^?" backward-delete-char
    bindkey -v '^H' backward-delete-char
    # to copy command previously deleted with C-u:
    bindkey '^Y' yank
    backward-kill-fname () {
        local WORDCHARS=${WORDCHARS/\/}
        zle backward-kill-word
    }
    zle -N backward-kill-fname
    # ctrl-w, delete file name
    bindkey '\C-w' backward-kill-fname
    # ctrl-backspace, does not work in konsole
    # bindkey "^H" backward-kill-fname
    # alt-backspace, delete all the word including '/'
    bindkey '^[^?' backward-kill-word

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
    # alt-o, alt-i: search for the command beginning
    bindkey "o" history-beginning-search-backward
    bindkey "i" history-beginning-search-forward
    if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
        source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        bindkey 'a' autosuggest-execute
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=5'
    fi
    # enable C-r in zsh vi mode
    bindkey "^R" history-incremental-search-backward

    # print function definition in which
    alias which="whence -cvf"
    # save directory name to pushd stack automatically
    setopt auto_pushd
    setopt pushd_ignore_dups

    # add local directory to additional completions path
    fpath=( ~/activity-public/computer-program-data/development "${fpath[@]}" )
    # tell zsh not to trust its cache when completing
    # There is a performance cost, but it is negligible on a typical desktop
    # setting today. (It isn't if you have $PATH on NFS, or a RAM-starved
    # system.)
    zstyle ":completion:*:commands" rehash 1

    # allow comments in interactive mode:
    setopt interactivecomments

    zle -N zle-line-init
    #zle -N zle-line-finish

    set_prompt () {
        # default value for main/viins/"" modes
        local MYPS1="+"
        if [[ "$KEYMAP" == "vicmd" ]]; then
            MYPS1=":"
        fi
        if (( FIRST_HISTCMD == 0)); then
            FIRST_HISTCMD=$HISTCMD
        fi
        PROMPT="$MYPS1$((HISTCMD-FIRST_HISTCMD))> "
    }

    set_prompt

    # Reset right prompt, on window resize
    TRAPWINCH ()
    {
        set_prompt
        zle reset-prompt
    }
    zle-line-init () {
        set_prompt
        zle reset-prompt
    }

    zle-keymap-select () {
        set_prompt
        zle reset-prompt
    }
    zle -N zle-keymap-select

    # With this widget, you can type `:q<RET>' to exit the shell from vicmd.
    ft-zshexit () {
        [[ -o hist_ignore_space ]] && BUFFER=' '
        BUFFER="${BUFFER}exit"
        zle .accept-line
    }
    zle -N q ft-zshexit
    zle -N ft-zshexit
    bindkey -M vicmd 'ZZ' ft-zshexit

    # don't use ctrl-d
    setopt ignore_eof
    ft-vi-cmd-cmd () {
        zle -M 'Use ZZ or `:q<RET>'\'' in CMD mode to exit the shell.'
    }
    
    zle -N ft-vi-cmd-cmd
    
    bindkey -M vicmd '^d' ft-vi-cmd-cmd
    bindkey '^d' ft-vi-cmd-cmd

    # reduce ESC delay to 0.01 sec
    export KEYTIMEOUT=1

	if [ -f /etc/inputrc ]; then
        eval "`sed -n 's/^/bindkey /; s/: / /p' /etc/inputrc`" > /dev/null
    fi
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
    # highlight the first ambiguous character in completion
    autoload -U colors
    colors
    zstyle ':completion:*' show-ambiguity "$color[fg-red]"
    # extended pattern matches:
    setopt EXTENDED_GLOB
    #allow tab completion in the middle of a word
    setopt COMPLETE_IN_WORD

    # correct typos in commands
    setopt correct
    ## keep background processes at full speed
    #setopt NOBGNICE
    ## restart running processes on exit
    #setopt HUP

    # history
    setopt INC_APPEND_HISTORY

    ## never ever beep ever
    #setopt NO_BEEP

    # automatically decide when to page a list of completions
    LISTMAX=0

    ## disable mail checking
    #MAILCHECK=0

    preexec () {
      print_preexec "$1"
    }

    preexec

    # set pre-prompt line
    precmd () {
      print_precmd
    }

    # some abbrev.s may be defined in local.sh
    local lapu="~/activity-public"
    local lape="~/activity-personal"
    local apu="~/nfs/s/activity-public"
    local ape="~/nfs/s/activity-personal"
    local wpe="~/nfs/s/works-personal"
    typeset -Ag abbreviations
    abbreviations=()

    abbreviations+=(
    "apu"	"$apu/"
    "lapu"	"$lapu/"
    "ape"	"$ape/"
    "lape"	"$lape/"
    "draf"	"$ape/draft_mak/"
    "wpu"	"~/nfs/s/works-public/"
    "wpe"	"$wpe/"
    "dpu"	"~/nfs/s/docs-public/"
    "dpe"	"~/nfs/s/docs-personal/"
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
    "cpd"	"$lapu/computer-program-data/"
    "cpdo"	"$lapu/computer-program-doc/"
    "cpli"	"computer-program-libraries/"
    "cpads"	"computer-program-algorithms_and_data_structures/"
    "capp"	"computer-applications/"
    "cpp"	"computer-program-proof/"
    "csym"	"computer-symbolic_calculations_computer_algebra/"
    "cvis"	"computer-visualization/"
    "eng"	"$ape/english"
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
    "lit"	"$wpe/literature/"
    "mus"	"$wpe/Music/"
    "pic"       "$lape/computer-program-data/pictures/"
    "phot"	"$wpe/Photos/"
    "nim"       "$apu/nim-stable/"
    "nim1"      "$apu/nim-stable-1-0/"
    "Nim"       "$apu/Nim/"
    "nim2"      "$apu/nim2/"
    "nimd"      "$apu/nim-devel/"
    )


    magic-abbrev-expand () {
         local left prefix
         left=$(echo -nE "$LBUFFER" | sed -e "s/[_a-zA-Z0-9]*$//")
         prefix=$(echo -nE "$LBUFFER" | sed -e "s/.*[^_a-zA-Z0-9]\([_a-zA-Z0-9]*\)$/\1/")
         LBUFFER=$left${abbreviations[$prefix]:-$prefix}
    }

    zle -N magic-abbrev-expand
    bindkey "^e" magic-abbrev-expand
    add_command () {
        print -sr $@
    }

elif [[ $CURSHELL == bash ]]; then
    echo "bash detected"
    set -o pipefail
    export HISTTIMEFORMAT=": %s:"
    #infinite history for bash
    export HISTSIZE=""

    export PS1="\#> "

    # preexec analogue of zsh for bash using DEBUG hook
    preexec_invoke_exec () {
        [ -n "$COMP_LINE" ] && return  # do nothing if completing
        [ "${FUNCNAME[-1]}" = source ] && return # reading .bashrc
        # don't cause a preexec for $PROMPT_COMMAND :
        [ "$BASH_COMMAND" = "$PROMPT_COMMAND" ] && return
        print_preexec "$BASH_COMMAND"
    }
    trap 'preexec_invoke_exec' DEBUG

    print_preexec

    export PROMPT_COMMAND=print_precmd
    add_command () {
        history -s $@
    }
else
    echo unknown shell
fi

difstring () {
  cmp -bl  <(echo "$1" ) <(echo "$2")
}

