#!/usr/bin/env bash

for group in vboxsf vboxusers dialout docker; do
    sudo usermod -a -G $group $USER
done

echo $'Section "ServerFlags"\n  Option "DontZap" "yes"\nEndSection' \
    | sudo tee /usr/share/X11/xorg.conf.d/dontzap.conf

# allow debugging with strace & gdb
echo kernel.yama.ptrace_scope = 0 | sudo tee /etc/sysctl.d/10-ptrace.conf
# allow dmesg
echo kernel.dmesg_restrict = 0 | sudo tee /etc/sysctl.d/11-dmesg.conf
sudo service procps restart

# improve interactivity by bfq I/O scheduler
#cp 60-ioschedulers.rules /etc/udev/rules.d/
