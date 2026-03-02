#!/bin/bash
set -e

WORKDIR="SleepyLinuxP"
ISO_NAME="SleepyLinux"

apt-get update
apt-get install -y live-build curl wget gnupg

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
mc nano wget curl rsync
apt-utils dialog
calamares calamares-settings-debian
cups printer-driver-cups-pdf
gvfs-fuse gvfs-backends
firmware-iwlwifi firmware-atheros firmware-brcm80211
blueman
vlc thunderbird thunderbird-l10n-hu
gimp simple-scan eog
imagemagick zstd
menulibre mugshot keepassxc geany
ntpsec zenity
gnupg gnupg2
wireguard wireguard-tools
libreoffice libreoffice-l10n-hu
audacious mpv
krita krita-l10n
nfs-common
veyon-service
bash-completion screen
samba smbclient cifs-utils
clamtk
openssh-server
apt-transport-https
ttf-mscorefonts-installer
gnupg1
libpam-google-authenticator
gnome-system-tools
gnome-online-accounts
molly-guard
kleopatra
geogebra
birdtray
polkitd
pkexec
dbus-user-session
accountsservice
xfce4-session
EOF

# autologin
mkdir -p config/includes.chroot/etc/lightdm/lightdm.conf.d
cat > config/includes.chroot/etc/lightdm/lightdm.conf.d/01-autologin.conf <<EOF
[Seat:*]
autologin-user=live
autologin-user-timeout=0
EOF

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

# Brave
curl -fsSLo /usr/share/keyrings/brave.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave.gpg] https://brave-browser-apt-release.s3.brave.com stable main" > /etc/apt/sources.list.d/brave.list
apt update
apt install -y brave-browser

# Signal
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > /usr/share/keyrings/signal.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/signal.gpg] https://updates.signal.org/desktop/apt xenial main" > /etc/apt/sources.list.d/signal.list
apt update
apt install -y signal-desktop

# TeamViewer
wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
dpkg -i teamviewer_amd64.deb || apt -f install -y
rm teamviewer_amd64.deb

# AEScrypt install
wget https://www.aescrypt.com/download/v4/linux/aescrypt_gui-4.5.0-Linux-x86_64.deb
dpkg -i aescrypt_gui-*.deb
rm aescrypt_gui-*.deb

# VeraCrypt (Debian 13 = Trixie)
wget https://launchpad.net/veracrypt/trunk/1.26.24/+download/veracrypt-1.26.24-Debian-13-amd64.deb
dpkg -i veracrypt-1.26.24-Debian-13-amd64.deb || apt -f install -y

echo "%sudo ALL=(ALL) NOPASSWD:/usr/bin/veracrypt" > /etc/sudoers.d/veracrypt
chmod 440 /etc/sudoers.d/veracrypt

# Live user
id -u live >/dev/null 2>&1 || useradd -m -s /bin/bash -G audio,cdrom,dip,floppy,video,plugdev,netdev,sudo live
echo "live:live" | chpasswd
chmod 700 /home/live
chown -R live:live /home/live

echo "== FULL BUILD DONE =="
EOF

chmod +x config/hooks/normal/999-full.hook.chroot

echo
echo "================================================="
echo "INTERAKTÍV SHELL fog indulni."
echo "Szerkeszd az /etc/skel mappát."
echo "Kilépés: exit"
echo "================================================="
echo

lb build

echo
echo "ISO kész:"
ls -lh *.iso

### javítás: ###
#sudo chroot chroot /bin/bash
#lb clean --binary
#lb binary
