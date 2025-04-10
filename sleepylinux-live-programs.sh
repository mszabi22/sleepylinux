#!/bin/bash
# # # Run this second in chroot # # #
green='\e[0;32m'
blue='\e[0;34m'
yellow='\e[0;33m'
white='\e[0;37m'

TOR_VERZIO="14.0.9"

########################################################################
echo -e "${yellow}rc-local setting...${white}"
echo '[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
 
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/rc-local.service

echo '#!/bin/sh -e
exit 0
' > /etc/rc.local

chmod +x /etc/rc.local
systemctl enable rc-local

########################################################################
echo -e "${yellow}Timezone setting...${white}"
apt install chrony -y
timedatectl set-timezone Europe/Budapest
timedatectl set-ntp on

########################################################################
echo -e "${yellow}Repository setting...${white}"
echo "deb https://ftp.debian.org/debian/ bookworm contrib main non-free non-free-firmware contrib
deb https://ftp.debian.org/debian/ bookworm-updates contrib main non-free non-free-firmware contrib
deb https://ftp.debian.org/debian/ bookworm-proposed-updates contrib main non-free non-free-firmware contrib
deb https://ftp.debian.org/debian/ bookworm-backports contrib main non-free non-free-firmware contrib
deb https://security.debian.org/debian-security/ bookworm-security contrib main non-free non-free-firmware contrib" > /etc/apt/sources.list
apt update
apt upgrade -y

########################################################################
echo -e "${yellow}Apps install...${white}"
apt install -y mc sudo ssh cups printer-driver-cups-pdf gvfs-fuse gvfs-backends apt-transport-https rsync curl wget \
    firmware-iwlwifi firmware-atheros firmware-brcm80211 blueman vlc thunderbird thunderbird-l10n-hu \
    gimp simple-scan gnupg gnupg2 gnupg1 eog zstd imagemagick alacarte gocryptfs mugshot keepassxc tor geany ntpsec zenity\
    libpam-google-authenticator gnome-system-tools wireguard wireguard-tools libreoffice-l10n-hu gnome-online-accounts \
    syncthing qrencode ecryptfs-utils audacious molly-guard kleopatra deluge borgbackup vorta ssh-askpass clamtk mpv smplayer \
    ntpdate firewalld firewall-config firewall-applet krita krita-l10n nfs-common flatpak ttf-mscorefonts-installer

echo "%sudo ALL = (ALL:ALL) NOPASSWD: /usr/bin/firewall-cmd" >> /etc/sudoers


sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install -y com.obsproject.Studio
########################################################################
echo -e "${yellow}Admin Tools? (i/n)${white}"
read ADMINTOOLS_INSTALL
if [ $ADMINTOOLS_INSTALL = 'i' ]; then
echo -e "${yellow}Admin Tools telepítése...${white}"
	apt install gprename gparted netdiscover sshuttle grub-customizer remmina remmina-plugin-rdp remmina-plugin-vnc \
	net-tools dnsutils arping chntpw hardinfo acpidump acpidump sysbench dislocker stress s-tui traceroute iputils-ping \
	wireshark tigervnc-viewer tigervnc-tools -y
	modprobe ecryptfs    	
fi
 
########################################################################
echo -e "${yellow}SSH setting...${white}"
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
echo "Include /etc/ssh/sshd_config.d/*.conf
Port 22
AllowUsers majorsza@*
PermitRootLogin no
PubkeyAuthentication yes
AuthorizedKeysFile	.ssh/authorized_keys .ssh/authorized_keys2
PasswordAuthentication no

KbdInteractiveAuthentication yes
UsePAM yes
ChallengeResponseAuthentication yes

X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem	sftp	/usr/lib/openssh/sftp-server" > /etc/ssh/sshd_config
sudo apt install libpam-google-authenticator
cp /etc/pam.d/sshd /root/pam.d_sshd.bak
echo "
# two-factor authentication via Google Authenticator
auth   required   pam_google_authenticator.so" >> /etc/pam.d/sshd
/etc/init.d/ssh restart

########################################################################
echo -e "${yellow}Brave install...${white}"    
apt install curl
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"| tee /etc/apt/sources.list.d/brave-browser-release.list
apt update
apt install brave-browser -y
echo "[Desktop Entry]
Version=1.0
Name=Brave Webböngésző
Exec=/usr/bin/brave-browser-stable %U
StartupNotify=true
Terminal=false
Icon=brave-browser
Type=Application
Categories=Network;WebBrowser;
MimeType=application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ipfs;x-scheme-handler/ipns;
Actions=new-window;new-private-window;

[Desktop Action new-window]
Name=Új ablak
Exec=/usr/bin/brave-browser-stable

[Desktop Action new-private-window]
Name=Inkognitó mód
Exec=/usr/bin/brave-browser-stable --incognito
" > /usr/share/applications/brave-browser.desktop

########################################################################
echo -e "${yellow}Tor Browser install...${white}"
cd /opt
wget https://www.torproject.org/dist/torbrowser/$TOR_VERZIO/tor-browser-linux-x86_64-$TOR_VERZIO.tar.xz
tar -xvJf tor-browser-*.tar.xz
rm tor-browser-*.tar.xz
chmod -R 755 /opt/tor-browser 
echo "#!/bin/bash
sudo chown -R $USER:$USER /opt/tor-browser
cd /opt/tor-browser
./start-tor-browser.desktop --register-app" > /usr/local/bin/tor-browser-setup
chmod +x /usr/local/bin/tor-browser-setup
cd

########################################################################
echo -e "${yellow}Signal install...${white}"
cd
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
cat signal-desktop-keyring.gpg | tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | tee /etc/apt/sources.list.d/signal-xenial.list
apt update && sudo apt install signal-desktop
rm signal-desktop-keyring.gpg

########################################################################
echo -e "${yellow}Viber install...${white}"
cd /usr/local/bin
wget https://download.cdn.viber.com/desktop/Linux/viber.AppImage
mv viber.AppImage viber
chmod +x viber
cd /usr/share/icons
wget -O viber-logo.png https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fzh.wizcase.com%2Fwp-content%2Fuploads%2F2020%2F02%2FVIBER-LOGO-1.png&f=1&nofb=1&ipt=95f0c86d8e9533c00e85b8621237d03bae171b5e9a253152513eb3bb4fa223e1&ipo=images
echo "[Desktop Entry]
Name=Viber
Exec=/usr/local/bin/viber
Icon=/usr/share/icons/viber-logo.png

Encoding=UTF-8
ExecutionMode=normal
Type=Application
Categories=Network;
Enabled=true" > /usr/share/applications/viber.desktop  

########################################################################
echo -e "${yellow}Standard Notes install...${white}"
cd /usr/share/icons
wget http://icons.iconarchive.com/icons/papirus-team/papirus-apps/512/standard-notes-icon.png
cd /usr/local/bin
wget https://github.com/standardnotes/app/releases/download/%40standardnotes%2Fdesktop%403.194.13/standard-notes-3.194.13-linux-x86_64.AppImage
mv standard-notes-*.AppImage standard-notes
chmod a+x standard-notes
echo "[Desktop Entry]
Name=Standard Notes
Exec=/usr/local/bin/standard-notes
Icon=/usr/share/icons/standard-notes-icon.png

Encoding=UTF-8
ExecutionMode=normal
Type=Application
Categories=Office;
Enabled=true" > /usr/share/applications/standard-notes.desktop

########################################################################
echo -e "${yellow}AEScrypt install...${white}"
wget https://www.aescrypt.com/download/v4/linux/aescrypt_gui-4.2.3-Linux-x86_64.deb
dpkg -i aescrypt_gui-4.2.3-Linux-x86_64.deb
########################################################################
echo -e "${yellow}VeraCrypt install...${white}"
cd
wget https://launchpad.net/veracrypt/trunk/1.26.7/+download/veracrypt-1.26.7-Debian-12-amd64.deb
dpkg -i veracrypt-1.26.7-Debian-12-amd64.deb
apt-get -f install -y
rm veracrypt-1.26.7-Debian-12-amd64.deb
apt-get -f install -y
echo "[Desktop Entry]
Type=Application
Name=VeraCrypt
GenericName=VeraCrypt volume manager
Comment=Create and mount VeraCrypt encrypted volumes
Icon=veracrypt
Exec=/usr/bin/veracrypt %f
Categories=Office;
Keywords=encryption,filesystem
Terminal=false
MimeType=application/x-veracrypt-volume;application/x-truecrypt-volume;" > /usr/share/applications/veracrypt.desktop
echo "%sudo  ALL = (ALL:ALL) NOPASSWD: /usr/bin/veracrypt" >> /etc/sudoers

########################################################################
echo -e "${yellow}TeamViewer install...${white}"
cd
wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
dpkg -i teamviewer_amd64.deb
apt-get -f install -y
rm teamviewer_amd64.deb

########################################################################
echo -e "${yellow}Winbox install...${white}"
mkdir /opt/winbox
cd /opt/winbox
wget https://download.mikrotik.com/routeros/winbox/4.0beta18/WinBox_Linux.zip
unzip WinBox_Linux.zip
rm WinBox_Linux.zip
echo "[Desktop Entry]
Name=Winbox
Exec=/opt/winbox/WinBox
Icon=/opt/winbox/assets/img/winbox.png

Encoding=UTF-8
ExecutionMode=normal
Type=Application
Categories=Application;Network;
Enabled=true" > /usr/share/applications/winbox.desktop
chmod -R 777 /opt/winbox/
########################################################################
echo -e "${yellow}Create user...${white}"
adduser user
########################################################################
echo -e "${green}DONE.${white}"
echo "LO!!!"
