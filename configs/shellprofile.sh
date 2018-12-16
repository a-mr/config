
echo "reading profile file..."
CURSHELL=`ps -p $$ | tail -1 | awk '{print $NF}'`

echo $DISPLAY > ~/.display-x11-$HOSTNAME

if [[ "$CURSHELL" == "/bin/zsh" || "$CURSHELL" == "zsh" ]]; then
    echo zsh detected
elif [[ "$CURSHELL" == "/bin/bash" || "$CURSHELL" == "bash" ]]; then
    echo bash detected
    . ~/.bashrc
fi

