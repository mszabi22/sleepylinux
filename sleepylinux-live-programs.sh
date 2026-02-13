#!/bin/bash
# # # Run this second in chroot # # #
green='\e[0;32m'
blue='\e[0;34m'
yellow='\e[0;33m'
white='\e[0;37m'
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
echo -e "${yellow}Repository setting...${white}"
echo "deb https://ftp.debian.org/debian/ trixie contrib main non-free non-free-firmware contrib
deb https://ftp.debian.org/debian/ trixie-updates contrib main non-free non-free-firmware contrib
deb https://ftp.debian.org/debian/ trixie-proposed-updates contrib main non-free non-free-firmware contrib
deb https://ftp.debian.org/debian/ trixie-backports contrib main non-free non-free-firmware contrib
deb https://security.debian.org/debian-security/ trixie-security contrib main non-free non-free-firmware contrib" > /etc/apt/sources.list
apt update
apt upgrade -y

########################################################################
echo -e "${yellow}Apps install...${white}"
apt install -y mc sudo ssh cups printer-driver-cups-pdf gvfs-fuse gvfs-backends apt-transport-https rsync curl wget \
    firmware-iwlwifi firmware-atheros firmware-brcm80211 blueman ttf-mscorefonts-installer vlc thunderbird thunderbird-l10n-hu \
    gimp simple-scan gnupg gnupg2 gnupg1 eog zstd imagemagick alacarte gocryptfs mugshot keepassxc tor geany ntpsec \
    libpam-google-authenticator gnome-system-tools wireguard wireguard-tools libreoffice-l10n-hu gnome-online-accounts \
    syncthing qrencode ecryptfs-utils audacious molly-guard kleopatra deluge mpv smplayer \
    obs-studio ffmpeg bleachbit flatpak handbrake gnome-calendar greybird-gtk-theme elementary-xfce-icon-theme adwaita-icon-theme \
	tango-icon-theme xfwm4-theme-breeze htop btop linux-cpupower cpupower-gui onionshare fastfetch
########################################################################
echo -e "${yellow}LocalSend install...${white}"
wget https://github.com/localsend/localsend/releases/download/v1.17.0/LocalSend-1.17.0-linux-x86-64.deb
dpkg -i LocalSend-1.17.0-linux-x86-64.deb
apt-get -f install -y
rm LocalSend-1.17.0-linux-x86-64.deb        
########################################################################
echo -e "${yellow}Admin Tools? (i/n)${white}"
read ADMINTOOLS_INSTALL
if [ $ADMINTOOLS_INSTALL = 'i' ]; then
echo -e "${yellow}Admin Tools telepítése...${white}"
	apt install gprename gparted netdiscover sshuttle grub-customizer remmina remmina-plugin-rdp remmina-plugin-vnc \
	net-tools dnsutils arping zenity chntpw hardinfo acpidump acpidump sysbench dislocker stress s-tui traceroute iputils-ping \
	wireshark tigervnc-viewer tigervnc-tools
	
	echo -e "${yellow}Winbox install...${white}"
	cd /opt
	mkdir winbox
	cd winbox
	wget https://download.mikrotik.com/routeros/winbox/4.0rc1/WinBox_Linux.zip
	unzip WinBox_Linux.zip
	ln -s /opt/winbox/WinBox /usr/local/bin/winbox
	ln -s /opt/winbox/assets/img/winbox.png /usr/share/icons/winbox.png
	rm WinBox_Linux.zip
	chmod -R 777 /opt/winbox
	
echo "[Desktop Entry]
Name=Winbox
Exec=/usr/local/bin/winbox
Icon=/usr/share/icons/winbox.png
 
Encoding=UTF-8
ExecutionMode=normal
Type=Application
Categories=Application;Network;
Enabled=true" > /usr/share/applications/winbox.desktop
	
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
sudo apt install jq -y
TOR_VERZIO="$(curl -s https://aus1.torproject.org/torbrowser/update_3/release/downloads.json | jq -r ".version")"
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
wget -O viber https://download.cdn.viber.com/desktop/Linux/viber.AppImage
chmod +x viber

cd /usr/share/icons
wget -O viber-logo.png https://www.freepnglogos.com/uploads/viber-png/viber-top-way-video-call-faster-full-tronzi-6.png

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
wget -O standard-notes https://github.com/standardnotes/app/releases/download/%40standardnotes/desktop%403.201.18/standard-notes-3.201.18-linux-x86_64.AppImage
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
cd
wget https://www.aescrypt.com/download/v4/linux/aescrypt_gui-4.5.0-Linux-x86_64.deb
dpkg -i aescrypt_gui-*.deb
rm aescrypt_gui-*.deb
########################################################################
echo -e "${yellow}VeraCrypt install...${white}"
if [ `cat /etc/issue | grep 12 | wc -l` = "1" ]; then
	wget https://launchpad.net/veracrypt/trunk/1.26.24/+download/veracrypt-1.26.24-Debian-12-amd64.deb
	dpkg -i veracrypt-1.26.24-Debian-12-amd64.deb
	apt-get -f install -y
fi

if [ `cat /etc/issue | grep 13 | wc -l` = "1" ]; then
	wget https://launchpad.net/veracrypt/trunk/1.26.24/+download/veracrypt-1.26.24-Debian-13-amd64.deb
	dpkg -i veracrypt-1.26.24-Debian-13-amd64.deb
	apt-get -f install -y
fi
echo "%sudo  ALL = (ALL:ALL) NOPASSWD: /usr/bin/veracrypt" >> /etc/sudoers

########################################################################
echo -e "${yellow}TeamViewer install...${white}"
cd
wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
dpkg -i teamviewer_amd64.deb
rm teamviewer_amd64.deb
########################################################################
echo -e "${yellow}Create user...${white}"
adduser user

echo -e "${yellow}LibreOffice eltávolítása...${white}"
sudo apt remove --purge libreoffice-*
sudo apt autoremove
sudo apt clean
echo "Új LibreOffice install!!!"
