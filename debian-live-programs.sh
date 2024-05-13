#!/bin/bash
# # # Run this second in chroot # # #
green='\e[0;32m'
blue='\e[0;34m'
yellow='\e[0;33m'
white='\e[0;37m'
TOR_VERZIO="13.0.14"
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
echo "deb https://ftp.debian.org/debian/ bookworm contrib main non-free non-free-firmware
deb https://ftp.debian.org/debian/ bookworm-updates contrib main non-free non-free-firmware
deb https://ftp.debian.org/debian/ bookworm-proposed-updates contrib main non-free non-free-firmware
deb https://ftp.debian.org/debian/ bookworm-backports contrib main non-free non-free-firmware
deb https://security.debian.org/debian-security/ bookworm-security contrib main non-free non-free-firmware" > /etc/apt/sources.list
apt update
apt upgrade -y

echo -e "${yellow}Apps install...${white}"
apt install -y mc sudo ssh cups printer-driver-cups-pdf gvfs-fuse gvfs-backends apt-transport-https rsync curl wget \
    firmware-iwlwifi firmware-atheros firmware-brcm80211 blueman ttf-mscorefonts-installer vlc \
    thunderbird thunderbird-l10n-hu gimp simple-scan gnupg gnupg2 gnupg1 eog zstd imagemagick menulibre \
    gprename gocryptfs mugshot keepassxc tor geany netdiscover sshuttle grub-customizer \
    ntpsec remmina remmina-plugin-rdp remmina-plugin-vnc net-tools dnsutils arping libpam-google-authenticator \
    gparted gnome-system-tools zenity wireguard wireguard-tools wine64 chntpw libreoffice-l10n-hu onionshare \
    gnome-online-accounts hardinfo syncthing qrencode ecryptfs-utils
    
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

echo -e "${yellow}Viber install...${white}"
cd /tmp
wget https://download.cdn.viber.com/cdn/desktop/Linux/viber.deb
dpkg -i viber.deb
apt-get -f install -y
rm -rf viber.deb

echo -e "${yellow}Tutanota client install...${white}"
cd /usr/local/bin
wget https://mail.tutanota.com/desktop/tutanota-desktop-linux.AppImage
mv tutanota-desktop-linux.AppImage tutanota-desktop
chmod +x tutanota-desktop

echo -e "${yellow}Standard Notes install...${white}"
cd /usr/share/icons
wget http://icons.iconarchive.com/icons/papirus-team/papirus-apps/512/standard-notes-icon.png
cd /usr/local/bin
wget https://github.com/standardnotes/app/releases/download/%40standardnotes/desktop%403.175.2/standard-notes-3.175.2-linux-x86_64.AppImage
mv standard-notes-3.175.2-linux-x86_64.AppImage standard-notes
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

echo -e "${yellow}GnuPG GUI install...${white}"
cd /usr/share/icons
wget https://seeklogo.com/images/G/gnupg-logo-1E470BD8D2-seeklogo.com.png
mv gnupg-logo-1E470BD8D2-seeklogo.com.png gnupg.png
wget https://download.gnupg.com/files/gnupg/gnupg-desktop-2.3.8.0-x86_64.AppImage
mv gnupg-desktop-2.3.8.0-x86_64.AppImage /usr/local/bin/gnupg-desktop    
chmod +x /usr/local/bin/gnupg-desktop
echo "[Desktop Entry]
Name=Kleopatra
Exec=/usr/local/bin/gnupg-desktop
Icon=/usr/share/icons/gnupg.png

Encoding=UTF-8
ExecutionMode=normal
Type=Application
Categories=Office;
Enabled=true" > /usr/share/applications/gnupg.desktop

echo -e "${yellow}AEScrypt install...${white}"
cd
wget https://www.aescrypt.com/download/v3/linux/AESCrypt-GUI-3.11-Linux-x86_64-Install.gz
gunzip AESCrypt-GUI-3.11-Linux-x86_64-Install.gz
chmod +x AESCrypt-GUI-3.11-Linux-x86_64-Install
./AESCrypt-GUI-3.11-Linux-x86_64-Install
rm AESCrypt-GUI-3.11-Linux-x86_64-Install
echo "[Desktop Entry]
Encoding=UTF-8
Name=AESCrypt
Tooltip=Encrypt or Decrypt a file using AESCrypt 
Comment=Encrypt or Decrypt a file using AESCrypt
Exec=/usr/bin/aescrypt-gui %f
ExecutionMode=normal
Type=Application
Icon=/usr/share/aescrypt/SmallLock.png
Categories=Office;
Enabled=true" > /usr/share/applications/AESCrypt.desktop

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

echo -e "${yellow}TeamViewer install${white}"
cd
wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
dpkg -i teamviewer_amd64.deb
apt-get -f install -y
rm teamviewer_amd64.deb

echo -e "${yellow}Winbox install...${white}"
cd /usr/share/icons
wget https://freesvg.org/img/winbox-mikrotik-icon.png
mv winbox-mikrotik-icon.png winbox.png
cd /usr/local/bin
wget https://mt.lv/winbox64
chmod a+x winbox64
echo "[Desktop Entry]
Name=Winbox
Exec=wine /usr/local/bin/winbox64
Icon=/usr/share/icons/winbox.png

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
