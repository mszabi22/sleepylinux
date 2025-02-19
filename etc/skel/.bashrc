if [ `whoami` = "root" ]; then
	PS1='\[\e[1;31m\][\u@\H \W]\$\[\e[0m\] '
    else
       PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\H\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi

source ~/.bash_aliases
export EDITOR=mcedit

if [ -f firewall.cmd ]; then
    sudo bash firewall.cmd
    rm firewall.cmd
fi