# SleepyLinux is just a customized Debian :)
- OS: Debian 13
- Architecture: amd64
- Locales=hu_HU.UTF-8 
- Keyboard-layouts=hu 
- Timezone=Europe/Budapest


<ins>Browsers:</ins>
- Brave
- Tor browser
- Firefox ESR

<ins>Messengers:</ins>
- Signal

<ins>Office:</ins>
- LibreOffice
- Standard Notes
- KeePassXC

<ins>Encryption/Secure tools:</ins>
- GnuPG GUI (Kleopatra)
- AEScrypt
- VeraCrypt
- Syncthing

<ins>Remote support:</ins>
- TeamViewer

<ins>Config tools:</ins>
- Winbox
- Active Directory member support script

<ins>Other added programs:</ins>

mc lshw wireshark gparted ntfs-3g hfsprogs partclone clonezilla sshfs nano firmware-iwlwifi firmware-atheros\
firmware-brcm80211 blueman ttf-mscorefonts-installer vlc thunderbird thunderbird-l10n-hu gimp simple-scan \
gnupg gnupg2 gnupg1 eog zstd imagemagick menulibre gprename gocryptfs mugshot geany netdiscover sshuttle \
grub-customizer ntpsec remmina remmina-plugin-rdp remmina-plugin-vnc net-tools dnsutils arping zenity \
libpam-google-authenticator gnome-system-tools wireguard wireguard-tools chntpw gnome-online-accounts\
ecryptfs-utils hardinfo gnome-mahjongg quadrapassel gnome-chess acpidump ssh-askpass sysbench clamtk dislocker

## <ins>Method of preparation:</ins>
1. Run debian-live-build.sh
2. Copy to chroot: debian-live-programs.sh, etc, usr/local/bin
3. Run debian-live-programs.sh


