#!/bin/bash
# Run this first
apt-get install live-build
lb clean
lb config noauto \
	--color \
	--architectures amd64 \
	--linux-flavours amd64:amd64 \
	--binary-images iso-hybrid \
	--distribution trixie \
	--debian-installer none \
	--archive-areas "contrib main non-free non-free-firmware" \
	--debootstrap-options "--variant=minbase" \
	--bootappend-live "boot=live persistence components hostname=SleepyLinux locales=hu_HU.UTF-8 keyboard-layouts=hu timezone=Europe/Budapest" \
	--image-name "SleepyLinux" \
	--iso-application SleepyLinux \
	--iso-preparer `date +%Y.%m.%d.` \
	--iso-publisher "Sleepy.hu" \
	--iso-volume "SleepyLinux"\
	--memtest none \
	--interactive shell

echo "mc network-manager net-tools wget openssh-client task-xfce-desktop xserver-xorg-core gparted ntfs-3g hfsprogs rsync dosfstools \
partclone sshfs nano calamares calamares-settings-debian apt-utils user-setup sudo dialog live-config live-config-systemd" > config/package-lists/my.list.chroot
# # #
lb build


### Módosítás ###
lb clean --binary
lb build
