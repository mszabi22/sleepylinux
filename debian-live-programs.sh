#!/bin/bash
# # # Run this second in chroot # # #
green='\e[0;32m'
blue='\e[0;34m'
yellow='\e[0;33m'
white='\e[0;37m'
TOR_VERZIO="14.0"
# # #
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

echo -e "${yellow}Timezone setting...${white}"
apt install chrony -y
timedatectl set-timezone Europe/Budapest
timedatectl set-ntp on

echo -e "${yellow}Repository setting...${white}"
echo "deb https://ftp.debian.org/debian/ bookworm contrib main non-free non-free-firmware contrib
deb https://ftp.debian.org/debian/ bookworm-updates contrib main non-free non-free-firmware contrib
deb https://ftp.debian.org/debian/ bookworm-proposed-updates contrib main non-free non-free-firmware contrib
deb https://ftp.debian.org/debian/ bookworm-backports contrib main non-free non-free-firmware contrib
deb https://security.debian.org/debian-security/ bookworm-security contrib main non-free non-free-firmware contrib" > /etc/apt/sources.list
apt update
apt upgrade -y

echo -e "${yellow}Apps install...${white}"
apt install -y mc sudo ssh cups printer-driver-cups-pdf gvfs-fuse gvfs-backends apt-transport-https rsync curl wget \
    firmware-iwlwifi firmware-atheros firmware-brcm80211 blueman ttf-mscorefonts-installer vlc \
    thunderbird thunderbird-l10n-hu gimp simple-scan gnupg gnupg2 gnupg1 eog zstd imagemagick menulibre \
    gprename gocryptfs mugshot keepassxc tor geany netdiscover sshuttle grub-customizer \
    ntpsec remmina remmina-plugin-rdp remmina-plugin-vnc net-tools dnsutils arping libpam-google-authenticator \
    gparted gnome-system-tools zenity wireguard wireguard-tools wine64 chntpw libreoffice-l10n-hu \
    gnome-online-accounts hardinfo syncthing qrencode ecryptfs-utils audacious acpidump molly-guard ddclient \
    kleopatra deluge gnome-mahjongg quadrapassel gnome-chess acpidump borg vorta
     
modprobe ecryptfs    

echo -e "${yellow}SSH setting...${white}"
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
echo "PubkeyAuthentication yes
PasswordAuthentication no
UsePAM yes
ChallengeResponseAuthentication yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem	sftp	/usr/lib/openssh/sftp-server
" > /etc/ssh/sshd_config
/etc/init.d/ssh restart

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

echo -e "${yellow}Tor Browser install...${white}"
cd /opt
wget https://www.torproject.org/dist/torbrowser/$TOR_VERZIO/tor-browser-linux-x86_64-$TOR_VERZIO.tar.xz
tar -xvJf tor-browser-*.tar.xz
rm tor-browser-*.tar.xz
chmod -R 755 /opt/tor-browser 
echo "#!/usr/bin/bash
cd /opt/tor-browser
./start-tor-browser.desktop --register-app
sudo chown -R \$USER:\$USER /opt/tor-browser" > /usr/local/bin/tor-browser-setup.sh
chmod +x /usr/local/bin/tor-browser-setup.sh
cd

echo -e "${yellow}Signal install...${white}"
cd
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
cat signal-desktop-keyring.gpg | tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | tee /etc/apt/sources.list.d/signal-xenial.list
apt update && sudo apt install signal-desktop

echo -e "${yellow}SimpleX chat install...${white}"
cd /usr/local/bin
wget -O simplex-desktop https://github.com/simplex-chat/simplex-chat/releases/latest/download/simplex-desktop-x86_64.AppImage
chmod +x simplex-desktop 

cd /usr/share/icons
wget https://simplex.chat/img/new/logo-dark.png -O simplex-logo.png

echo "[Desktop Entry]
Name=SimpleX.chat
Exec=/usr/local/bin/simplex-desktop
Icon=/usr/share/icons/simplex-logo.png

Encoding=UTF-8
ExecutionMode=normal
Type=Application
Categories=Network;
Enabled=true" > /usr/share/applications/simplex-desktop.desktop  

echo -e "${yellow}Viber install...${white}"
cd /tmp
wget https://download.cdn.viber.com/cdn/desktop/Linux/viber.deb
dpkg -i viber.deb
apt-get -f install -y
rm -rf viber.deb

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

echo -e "${yellow}AEScrypt install...${white}"
cd /tmp
wget https://www.aescrypt.com/download/v4/linux/aescrypt_gui-4.0.5-Linux-x86_64.tar.gz
tar xzf *.tar.gz
cd aescrypt_gui-4.0.5-Linux-x86_64
cp bin/* /usr/local/bin/
cp -rf share/* /usr/share/
rm -rf /tmp/aescrypt_gui-4.0.5-Linux-x86_64

echo -e "${yellow}VeraCrypt install...${white}"
cd
wget https://launchpad.net/veracrypt/trunk/1.26.7/+download/veracrypt-1.26.7-Debian-12-amd64.deb
dpkg -i veracrypt-1.26.7-Debian-12-amd64.deb
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


echo -e "${yellow}RustDesk? (i/n)${white}"
read RUSTDESK_INSTALL
if [ $RUSTDESK_INSTALL = 'i' ]; then
	echo -e "${yellow}RustDesk install..${white}"
	cd /usr/local/bin
	wget https://github.com/rustdesk/rustdesk/releases/download/1.3.1/rustdesk-1.3.1-x86_64.AppImage
	mv rustdesk-1.3.1-x86_64.AppImage rustdesk
	chmod +x rustdesk
cd /usr/share/icons
wget -q -O rustdesk-logo.png https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.myqnap.org%2Fwp-content%2Fuploads%2Frustdesk-logo.png&f=1&nofb=1&ipt=31c1fd688cfe78d356d7f6339be7858c1972b3270cb2c2ebdbbdeb72fccedc0f&ipo=images
	
echo "[Desktop Entry]
Name=RustDesk
Exec=/usr/local/bin/rustdesk
Icon=/usr/share/icons/rustdesk-logo.png

Encoding=UTF-8
ExecutionMode=normal
Type=Application
Categories=Network;
Enabled=true" > /usr/share/applications/rustdesk.desktop 	
fi

echo -e "${yellow}TeamViewer install${white}"
cd
wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
dpkg -i teamviewer_amd64.deb
apt-get -f install -y
rm teamviewer_amd64.deb

echo -e "${yellow}Winbox install...${white}"
cd /usr/local/bin
wget https://download.mikrotik.com/routeros/winbox/4.0beta9/WinBox_Linux.zip
unzip WinBox_Linux.zip
rm WinBox_Linux.zip
mv WinBox winbox
echo "[Desktop Entry]
Name=Winbox
Exec=/usr/local/bin/winbox
Icon=/usr/local/bin/assets/img/winbox.png

Encoding=UTF-8
ExecutionMode=normal
Type=Application
Categories=Application;Network;
Enabled=true" > /usr/share/applications/winbox.desktop

echo -e "${green}DONE.${white}"

echo "CHECK list:"
echo "- Lightdm"
echo "- /etc/skel"
echo "- /usr/local/bin/join-ad"
echo "- /usr/local/bin/tor-browser-setup"
