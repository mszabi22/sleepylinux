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
	wget https://download.mikrotik.com/routeros/winbox/4.0.1/WinBox_Linux.zip
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
wget https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/standard-notes.png
cd /usr/local/bin
wget -O standard-notes https://github.com/standardnotes/app/releases/download/%40standardnotes/desktop%403.201.18/standard-notes-3.201.18-linux-x86_64.AppImage
chmod a+x standard-notes
echo "[Desktop Entry]
Name=Standard Notes
Exec=/usr/local/bin/standard-notes
Icon=/usr/share/icons/standard-notes.png

Encoding=UTF-8
ExecutionMode=normal
Type=Application
Categories=Office;
Enabled=true" > /usr/share/applications/standard-notes.desktop
########################################################################
echo -e "${yellow}root passwd...${white}"
passwd


