
echo "reading profile file..."
CURSHELL=`ps -p $$ | tail -1 | awk '{print $NF}'`

echo $DISPLAY > ~/.display-x11-$HOSTNAME

# some systems provide their local settings here (it is not loaded if
# .bash_profile is present)
if [ -f ~/.profile ]; then
    . ~/.profile
fi

if [[ "$CURSHELL" == "/bin/zsh" || "$CURSHELL" == "zsh" ]]; then
    echo zsh detected
elif [[ "$CURSHELL" == "/bin/bash" || "$CURSHELL" == "bash" \
     || "$CURSHELL" == "/usr/bin/bash" ]]; then
    echo bash detected
else
    echo unknown shell detected
fi

. ~/.bashrc

