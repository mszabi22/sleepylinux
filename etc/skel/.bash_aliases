# APT #
alias apt*='sudo apt-get autoremove '
alias apt+='sudo apt install '
alias apt-='sudo apt remove '
alias update='sudo apt update; sudo apt upgrade; sudo apt-get clean; sudo chmod 777 ~/last_update.txt;sudo echo "Last update: `date +%Y.%m.%d.%H:%M`" > ~/last_update.txt'
alias update-dist='sudo apt update; sudo apt dist-upgrade; sudo apt-get clean'
alias windows-licence-key="sudo acpidump -n MSDM"

