# APT #
alias apt*='sudo apt-get autoremove '
alias apt+='sudo apt install '
alias apt-='sudo apt remove '
alias update='sudo apt update; sudo apt upgrade; sudo apt-get clean; sudo chmod 777 ~/last_update.txt;sudo echo "Last update: `date +%Y.%m.%d.%H:%M`" > ~/last_update.txt'
alias update-dist='sudo apt update; sudo apt dist-upgrade; sudo apt-get clean'
alias windows-licence-key='sudo acpidump -n MSDM'

# apt #
alias apt*='sudo apt autoremove '
alias apt+='sudo apt install '
alias apt-='sudo apt remove '
alias update='sudo apt update; sudo apt upgrade; sudo chmod 777 ~/last_update.txt;sudo echo "Last update: `date +%Y.%m.%d.%H:%M`" > ~/last_update.txt'

alias pwgen-readable='pwgen -B -s 8 10 -1 -0 -c -v'

vdi2qcow() { qemu-img convert -p -f vdi -O qcow2 "$1" "${1%.vdi}.qcow2"; }
qcow2resize() { qemu-img resize "$1" "$2"; }

alias teszt-cpu='stress-ng --cpu 0 --timeout 300s --metrics'
alias teszt-mem='stress-ng --vm 2 --vm-bytes 75% --timeout 300s --metrics'
alias teszt-kombinalt='stress-ng --cpu 0 --vm 2 --vm-bytes 75% --hdd 1 --timeout 600s --metrics'