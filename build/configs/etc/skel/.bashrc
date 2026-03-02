if [ `whoami` = "root" ]; then
	PS1='\[\e[1;31m\][\u@\H \W]\$\[\e[0m\] '
    else
       PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\H\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi

if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

source ~/.bash_aliases
export EDITOR=mcedit



