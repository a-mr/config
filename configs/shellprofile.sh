
echo "reading profile file..."
CURSHELL=`ps -p $$ | tail -1 | awk '{print $NF}'`

if [ -z "$HOSTNAME" ]; then  # for Zsh
    export HOSTNAME=$HOST
fi
echo $DISPLAY > ~/.display-x11-$HOSTNAME

# some systems provide their local settings here (it is not loaded if
# .bash_profile is present)
if [ -f ~/.profile ]; then
    echo Loading ~/.profile
    . ~/.profile
fi

if [[ "$CURSHELL" == "/bin/zsh" || "$CURSHELL" == "zsh" ]]; then
    echo profile: zsh detected
elif [[ "$CURSHELL" == "/bin/bash" || "$CURSHELL" == "bash" \
     || "$CURSHELL" == "/usr/bin/bash" ]]; then
    echo profile: bash detected
    # assuming bash is loaded by default, so set environment here:
    . ~/.bashrc
else
    echo unknown shell detected
fi


