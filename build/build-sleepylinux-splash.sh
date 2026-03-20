#!/bin/bash
set -e

WORKDIR="SleepyLinux"
ISO_NAME="SleepyLinux"

apt-get update
apt-get install -y live-build curl wget gnupg  shim-signed grub-efi-amd64-signed

rm -rf $WORKDIR
mkdir $WORKDIR
cd $WORKDIR

lb clean

lb config noauto \
  --mode debian \
  --distribution trixie \
  --architectures amd64 \
  --linux-flavours amd64 \
  --binary-images iso-hybrid \
  --debian-installer none \
  --archive-areas "main contrib non-free non-free-firmware" \
  --debootstrap-options "--variant=minbase" \
  --bootappend-live "boot=live username=live persistence components hostname=SleepyLinux locales=hu_HU.UTF-8 keyboard-layouts=hu timezone=Europe/Budapest" \
  --image-name "$ISO_NAME" \
  --iso-application "$ISO_NAME" \
  --iso-publisher "Sleepy.hu" \
  --iso-volume "$ISO_NAME" \
  --memtest none \
  --interactive shell 

mkdir -p config/package-lists

cat > config/package-lists/desktop.list.chroot <<EOF
systemd-sysv
live-boot
live-config
live-config-systemd
adduser
passwd
login
sudo
task-xfce-desktop
lightdm
lightdm-gtk-greeter
xserver-xorg-core
network-manager

mc
nano
wget
curl
rsync
apt-utils
dialog

calamares
calamares-settings-debian

cups
printer-driver-cups-pdf
gvfs-fuse
gvfs-backends

firmware-iwlwifi
firmware-atheros
firmware-brcm80211

blueman
vlc
thunderbird
thunderbird-l10n-hu
gimp
simple-scan
eog
imagemagick
zstd

firefox-esr
firefox-esr-l10n-hu

menulibre
alacarte
mugshot
keepassxc
geany

ntpsec
zenity

gnupg

wireguard
wireguard-tools

libreoffice
libreoffice-l10n-hu

audacious
mpv
smplayer

krita
krita-l10n

nfs-common

bash-completion
screen

samba
smbclient
cifs-utils

clamtk
openssh-server
apt-transport-https
ttf-mscorefonts-installer
libpam-google-authenticator

gnome-system-tools
gnome-online-accounts
gnome-calendar

molly-guard
kleopatra
geogebra
birdtray

polkitd
pkexec
dbus-user-session
accountsservice
xfce4-session

htop
btop
linux-cpupower
cpupower-gui

onionshare
fastfetch
git
obs-studio
flatpak
handbrake
deluge
syncthing
qrencode
qreator
ecryptfs-utils
tor
ffmpeg
bleachbit

greybird-gtk-theme
elementary-xfce-icon-theme
adwaita-icon-theme
tango-icon-theme
xfwm4-theme-breeze

gocryptfs
EOF

# autologin
mkdir -p config/includes.chroot/etc/lightdm/lightdm.conf.d
cat > config/includes.chroot/etc/lightdm/lightdm.conf.d/01-autologin.conf <<EOF
[Seat:*]
autologin-user=live
autologin-user-timeout=0
EOF

# Plymouth téma fájlok
mkdir -p config/includes.chroot/usr/share/plymouth/themes/sleepyhu

cat > config/includes.chroot/usr/share/plymouth/themes/sleepyhu/sleepyhu.plymouth <<EOF
[Plymouth Theme]
Name=CiszterciLinux
Description=CiszterciLinux boot splash
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/sleepyhu
ScriptFile=/usr/share/plymouth/themes/sleepyhu/sleepyhu.script
EOF

cat > config/includes.chroot/usr/share/plymouth/themes/sleepyhu/sleepyhu.script <<'EOF'
wallpaper_image = Image("desktop-grub.png");
screen_width = Window.GetWidth();
screen_height = Window.GetHeight();

scaled = wallpaper_image.Scale(screen_width, screen_height);
sprite = Sprite(scaled);
sprite.SetX(0);
sprite.SetY(0);
sprite.SetZ(-100);
EOF

# GRUB háttérkép config (chroot-beli, telepített rendszerhez)
mkdir -p config/includes.chroot/etc/default/grub.d
cat > config/includes.chroot/etc/default/grub.d/99-sleepyhu.cfg <<EOF
GRUB_BACKGROUND="/boot/grub/sleepyhu-grub.png"
GRUB_TIMEOUT=5
EOF

# GRUB háttérkép a LIVE ISO bootloaderhez
# Az lb binary a config/bootloaders/grub-pc/splash.png-t automatikusan használja
mkdir -p config/bootloaders/grub-pc
# A képet az interaktív shellből másoljuk ide (ld. üzenet lent)

# CHROOT HOOK
mkdir -p config/hooks/normal

cat > config/hooks/normal/999-full.hook.chroot <<'EOF'
#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections

# repo
cat > /etc/apt/sources.list <<REPO
deb https://ftp.debian.org/debian trixie main contrib non-free non-free-firmware
deb https://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
deb https://ftp.debian.org/debian trixie-updates main contrib non-free non-free-firmware
deb https://ftp.debian.org/debian trixie-backports main contrib non-free non-free-firmware

# # # Sleepy.hu MIRROR
#deb https://mirror.sleepy.hu/debian trixie main contrib non-free non-free-firmware
#deb https://mirror.sleepy.hu/debian-security trixie-security main contrib non-free non-free-firmware
#deb http://mirror.sleepy.hu/debian trixie-backports main contrib non-free non-free-firmware
REPO

apt update
apt -y upgrade

# SSH hardening
apt install -y openssh-server libpam-google-authenticator
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
cat > /etc/ssh/sshd_config <<SSH
Port 22
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
KbdInteractiveAuthentication yes
UsePAM yes
ChallengeResponseAuthentication yes
X11Forwarding yes
Subsystem sftp /usr/lib/openssh/sftp-server
SSH

echo "auth required pam_google_authenticator.so" >> /etc/pam.d/sshd
ssh-keygen -A

# # #
# Brave
curl -fsSLo /usr/share/keyrings/brave.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave.gpg] https://brave-browser-apt-release.s3.brave.com stable main" > /etc/apt/sources.list.d/brave.list
apt update
apt install -y brave-browser

# # #
# Signal
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > /usr/share/keyrings/signal.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/signal.gpg] https://updates.signal.org/desktop/apt xenial main" > /etc/apt/sources.list.d/signal.list
apt update
apt install -y signal-desktop

# # #
# TeamViewer
wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
dpkg -i teamviewer_amd64.deb || apt -f install -y
rm teamviewer_amd64.deb

# # #
# AEScrypt install
wget https://www.aescrypt.com/download/v4/linux/aescrypt_gui-4.5.0-Linux-x86_64.deb
dpkg -i aescrypt_gui-*.deb
rm aescrypt_gui-*.deb

# # #
# VeraCrypt (Debian 13 = Trixie)
wget https://launchpad.net/veracrypt/trunk/1.26.24/+download/veracrypt-1.26.24-Debian-13-amd64.deb
dpkg -i veracrypt-1.26.24-Debian-13-amd64.deb || apt -f install -y
echo "%sudo ALL=(ALL) NOPASSWD:/usr/bin/veracrypt" > /etc/sudoers.d/veracrypt
chmod 440 /etc/sudoers.d/veracrypt
rm -rf veracrypt-*

# # #
# Plymouth téma aktiválása + GRUB háttérkép (telepített rendszerhez)
if [ -f /usr/share/images/desktop-base/desktop-grub.png ]; then
  cp /usr/share/images/desktop-base/desktop-grub.png \
     /usr/share/plymouth/themes/sleepyhu/desktop-grub.png
  mkdir -p /boot/grub
  cp /usr/share/images/desktop-base/desktop-grub.png \
     /boot/grub/sleepyhu-grub.png
fi
plymouth-set-default-theme sleepyhu
update-initramfs -u

# # #
echo "== FULL BUILD DONE =="
EOF
chmod +x config/hooks/normal/999-full.hook.chroot

echo
echo "================================================="
echo "INTERAKTÍV SHELL fog indulni."
echo "Szerkeszd az /etc/skel mappát."
echo "A képet másold be (Plymouth + GRUB live + GRUB telepített):"
echo "  SRC=/usr/share/images/desktop-base/desktop-grub.png"
echo "  cp \$SRC /usr/share/plymouth/themes/sleepyhu/desktop-grub.png"
echo "  mkdir -p /boot/grub"
echo "  cp \$SRC /boot/grub/sleepyhu-grub.png"
echo ""
echo "  -- és a live ISO GRUB háttérhez (chroot-on KÍVÜL, host-on):"
echo "  cp <képed>.png /DATA/LIVE/CiszterciLinux/config/bootloaders/grub-pc/splash.png"
echo ""
echo "Kilépés: exit"
echo "================================================="
echo

lb build

echo
DATUM=`date +%Y.%m.%d`; mv SleepyLinux-amd64.hybrid.iso SleepyLinux-$DATUM-amd64.iso; md5sum SleepyLinux-$DATUM-amd64.iso > SleepyLinux-$DATUM-amd64.iso.md5; chown -R majorsza:majorsza SleepyLinux-*
echo "ISO kész:"
ls -lh *.iso

### javítás: ###
#sudo chroot chroot /bin/bash
#lb clean --binary
#lb binary
