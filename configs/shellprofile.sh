
echo "reading profile file..."
CURSHELL=`ps -p $$ | tail -1 | awk '{print $NF}'`

echo $DISPLAY > ~/.display-x11-$HOSTNAME

if [[ "$CURSHELL" == "/bin/zsh" || "$CURSHELL" == "zsh" ]]; then
    echo zsh detected
elif [[ "$CURSHELL" == "/bin/bash" || "$CURSHELL" == "bash" ]]; then
    echo bash detected
    . ~/.bashrc
fi

if [ -e /home/andreymak/.nix-profile/etc/profile.d/nix.sh ]; then . /home/andreymak/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
