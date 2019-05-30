#!/usr/bin/env bash

INS="apt-get install -y"
INSB="apt-get build-dep -y"

$INSB ocaml

$INS mercurial vim gawk ssh mc gkrellm zsh tcsh screen tmux lm-sensors sshpass xclip iftop ethtool traceroute rlwrap suckless-tools xdelta3 elinks cvs subversion mercurial tortoisehg bzr git-core gitk darcs emacs emacs-nox emacs23-nox rsync

