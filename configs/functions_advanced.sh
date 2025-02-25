
difftree () {
    colordiff <(cd "$1"; find .|sort) <(cd "$2"; find .|sort)|p
}


FIRST_HISTCMD=0

short_dir () {
    local name=$force_window_name
    if [ -z "$name" ]; then
        name="${PWD##*/}"  # get last part of the path
        if [ ${#name} -gt 10 ]; then
            name="${name:0:4}~${name:0-4}"
        fi
    else
        name="|$name"
    fi
    echo $name
}

# print something before command next command prompt
print_precmd () {
    local RESULT=$?
    local finish_time="`curtime`"
    if [ ! -z "$additional_pre_cmd" ]; then
        eval $additional_pre_cmd
    fi
    local num_jobs="`jobs | wc -l`"
    local exe_time
    if [[ $CURSHELL == zsh ]]; then
        exe_time=$((finish_time-start_time))
    else
        exe_time=`awk "BEGIN { print $finish_time-$start_time }"`
    fi
    local curdir=`dirs -p | head -n1`
    local info=$(printf "%s(%.2f)" "$(date +%H:%M:%S)" "$exe_time")
    if [[ $num_jobs != "0" ]]; then
        info+="  === $num_jobs === "
    fi
    info+=" $curdir"
    #show repository branch if requested
    if [ "$wrepo" != "none" ]; then
        info+=" '$(bra -safe) $(datshort)'"
    fi
    if (( $RESULT == 0 )); then
        fill_echo $stout$cyan " $info"
    # not found or SIGPIPE received
    elif  (( $RESULT == 127 || $RESULT == 141 )); then
        warning_echo "exit=$RESULT; $info"
    else
        error_echo "exit=$RESULT; $info"
    fi
    local name=`short_dir`
    # set the titles to last path component of working directory
    case "$TERM" in
      screen*)
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
      screen*)
        DISPLAY=`cat $HOME/.display-x11-$HOSTNAME`
        if [ ! -z "$DISPLAY" ]; then
            export DISPLAY
        fi
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
        local short_cmd=$a
        if [ ${#a} -gt 10 ]; then
            short_cmd="${a:0:5}"
        fi
        local dir_name=`short_dir`
        local name="$dir_name.$short_cmd"
        # See screen(1) "TITLES (naming windows)".
        # "\ek" and "\e\" are the delimiters for screen(1) window titles
        # set screen title
        echo -ne "\ek$name\e\\"
        # must (re)set xterm title
        echo -ne "\e]0;${PWD##*/}> $a\a"
        ;;
      rxvt|rxvt-256color|rxvt-unicode|xterm|xterm-color|xterm-256color)
        echo -ne "\e]0;${PWD##*/}> $a\a"
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
    # swap t and j:
    bindkey -M vicmd "j" vi-find-next-char-skip
    bindkey -M vicmd "t" down-line-or-history
    # bind C-t to Return
    bindkey "^T" accept-line
    bindkey -M vicmd "^T" accept-line

    # home/end in gnome terminal
    bindkey  "^[[H"   beginning-of-line
    bindkey  "^[[F"   end-of-line
    # my convenience keybindings
    bindkey -M vicmd "y" beginning-of-line
    bindkey -M vicmd "u" end-of-line
    bindkey -v "y" beginning-of-line
    bindkey -v "u" end-of-line
    # in putty:
    bindkey  "^[[1~"   beginning-of-line
    bindkey  "^[[4~"   end-of-line
    # (hopefully) in many other terminals:
    bindkey "${terminfo[khome]}" beginning-of-line
    bindkey "${terminfo[kend]}" end-of-line
    # alt-o, alt-i: search for the command beginning
    bindkey "o" history-beginning-search-backward
    bindkey "i" history-beginning-search-forward
    bindkey -s "e" '\e'
    if [ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
        source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
        bindkey 'a' autosuggest-execute
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=5'
    elif [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
        source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        bindkey 'a' autosuggest-execute
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=5'
    fi
    # enable C-r in zsh vi mode
    bindkey "^R" history-incremental-search-backward

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

    function my_download_history () { 
        fc -R
        echo Updated history
        zle reset-prompt
    }
    zle -N my_download_history
    bindkey 'r' my_download_history

    function run_last_buffer () { 
        local line=`cat ~/tmp/buffer2`
        if [ ! -z "$BUFFER" ]; then
          BUFFER="$BUFFER $line"
          zle accept-line
        fi
    }
    zle -N run_last_buffer
    bindkey "b" run_last_buffer

    function run_tee () { 
        if [ ! -z "$BUFFER" ]; then
          BUFFER="$BUFFER 2>&1 | tee ~/tmp/buffer3"
          zle accept-line
        fi
    }
    zle -N run_tee
    bindkey "t" run_tee

    function run_pager () { 
        if [ ! -z "$BUFFER" ]; then
          BUFFER="$BUFFER 2>&1 | less"
          zle accept-line
        fi
    }
    zle -N run_pager
    bindkey "p" run_pager

    function run_vim_pager () { 
        if [ ! -z "$BUFFER" ]; then
          BUFFER="$BUFFER 2>&1 | decolorize | vim -c \"setlocal buftype=nofile bufhidden=hide noswapfile\" -"
          zle accept-line
        fi
    }
    zle -N run_vim_pager
    bindkey "v" run_vim_pager

    function run_pb_pager () { 
        if [ ! -z "$BUFFER" ]; then
          BUFFER="$BUFFER 2>&1 | pb"
          zle accept-line
        fi
    }
    zle -N run_pb_pager
    bindkey "n" run_pb_pager

    function run_cd_previous () { 
        if [ -z "$BUFFER" ]; then
            BUFFER="cd -"
            zle accept-line
        else
            echo
            echo line is not empty
            zle reset-prompt
        fi
    }
    zle -N run_cd_previous
    bindkey "^o" run_cd_previous

    function run_help_pager () { 
        if [ ! -z "$BUFFER" ]; then
          BUFFER="$BUFFER --help 2>&1 | less"
          zle accept-line
        fi
    }
    zle -N run_help_pager
    bindkey "h" run_help_pager

    function run_man_pager () { 
        if [ ! -z "$BUFFER" ]; then
          BUFFER="mm $BUFFER"
          zle accept-line
        fi
    }
    zle -N run_man_pager
    bindkey "k" run_man_pager

    autoload -Uz compinit
    compinit
    # immediately open completion choice menu
    setopt no_list_ambiguous

    # Start to complete `cl` command by files & dirs immediately:
    smart-complete-space() {
        # Get the current command line input
        local -r BUFFER_CONTENTS="${BUFFER}"
        if [[ "${BUFFER_CONTENTS}" == cl* ]]; then
            zle self-insert; zle complete-word _files
        else
            zle self-insert
        fi
    }
    zle -N smart-complete-space
    bindkey " " smart-complete-space

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

    # define function to be able to use `local` properly:

    set_abbrevs() {
    # some abbrev.s may be defined in local.sh
    local lapu="~/activity-public"
    local lape="~/activity-personal"
    local share_root
    if [ -d ~/nfs ]; then
        share_root="~/nfs/s"
    else
        share_root="~"
    fi
    local apu="$share_root/activity-public"
    local ape="$share_root/activity-personal"
    local wpe="$share_root/works-personal"
    local dpu="$share_root/docs-public"
    typeset -Ag abbreviations
    abbreviations=()

    abbreviations+=(
    "cpd"	"$lapu/computer-program-data/"
    )
    if [ -d ~/nfs ]; then
    abbreviations+=(
    # general directories
    "s"         "$share_root/"
    "apu"	"$apu/"
    "lapu"	"$lapu/"
    "ape"	"$ape/"
    "lape"	"$lape/"
    "wpe"	"$wpe/"
    # software to save so that it's not lost
    "soft"      "$share_root/software/"
    # VBox virtual machines
    "vbox"      "$share_root/vbox/"
    # my artifacts and projects
    "draf"	"$ape/draft_mak/"
    "wpu"	"$share_root/works-public/"
    "nims"      "$apu/nim-stable/"
    "nim1"      "$apu/nim-stable-1-0/"
    "Nim"       "$apu/Nim/"
    "nim2"      "$apu/nim2/"
    "nimd"      "$apu/nim-devel/"
    "nimd2"     "$apu/nim-devel2/"
    # personal materials/literature
    # # misc specifications
    "dau"	"$share_root/docs-aux/"
    # # bueraucratic
    "dpe"	"$share_root/docs-personal/"
    "lit"	"$wpe/literature/"
    "lan"	"$wpe/languages/"
    "mus"	"$wpe/Music/"
    "pic"       "$wpe/pictures/"
    "phot"	"$wpe/Photos/"
    # documents
    "dpu"	"$dpu"
    "nlp"	"$dpu/computer-speech\&natural_languages-processing/"
    "cpc"	"$dpu/computer-program-common/"
    "cps"	"$dpu/computer-program-system/"
    "cpli"	"$dpu/computer-program-libraries/"
    "algo"	"$dpu/computer-program-algorithms_and_data_structures/"
    )
    fi
    # historical abbreviations:
    #"cpla"	"$dpu/computer-program-languages/"
    #"eng"	"$ape/english/"
    #"ppe"	"physics-particle-experiment/"
    #"ppt"	"physics-particle-theory/"
    #"qm"	"quantum_mechanics/"
    #"qft"	"quantum_field_theory/"
    #"pc"	"physics-common/"
    #"cml"	"computer-machine_learning/"
    #"cnm"	"computer-numerical_methods/"
    #"capp"	"computer-applications/"
    #"cpp"	"computer-program-proof/"
    #"csym"	"computer-symbolic_calculations_computer_algebra/"
    #"cvis"	"computer-visualization/"
    #"mal"	"mathematics-algebra-linear/"
    #"mc"	"mathematics-common/"
    #"mca"	"mathematics-complex_analysis/"
    #"md"	"mathematics-discrete/"
    #"mfa"	"mathematics-functional_analysis/"
    #"mgt"	"mathematics-group_theory/"
    #"ml"	"mathematics-logic/"
    #"ms"	"mathematics-statistics/"
    #"msdp"	"mathematics-statistics&data_processing/"
    #"mt"	"mathematics-topology/"
    #"mmp"	"mathematics-mathematical_physics/"
    } # end set_abbrevs
    set_abbrevs


    magic-abbrev-expand () {
         local left prefix
         left=$(echo -nE "$LBUFFER" | sed -e "s/[_a-zA-Z0-9]*$//")
         prefix=$(echo -nE "$LBUFFER" | sed -e "s/.*[^_a-zA-Z0-9]\([_a-zA-Z0-9]*\)$/\1/")
         LBUFFER=$left${abbreviations[$prefix]:-$prefix}
    }

    zle -N magic-abbrev-expand
    bindkey "^e" magic-abbrev-expand

    function cd_expand_abbrev () { 
        zle magic-abbrev-expand
        if [ -z "$BUFFER" ]; then
            echo
            printf "%s\n" ${(k)abbreviations} | sort | column
            zle reset-prompt
        else
          BUFFER="cdf $BUFFER && ls"
          zle accept-line
        fi
    }
    zle -N cd_expand_abbrev
    bindkey "c" cd_expand_abbrev

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

