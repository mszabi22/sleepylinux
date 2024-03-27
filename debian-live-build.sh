#!/bin/bash
# Run this first
apt-get install live-build
lb clean
lb config noauto \
	--color \
	--architectures amd64 \
	--linux-flavours amd64:amd64 \
	--binary-images iso-hybrid \
	--distribution bookworm \
	--debian-installer live \
	--debian-installer-distribution bookworm \
	--debian-installer-gui true \
	--archive-areas "contrib main non-free non-free-firmware" \
	--debootstrap-options "--variant=minbase" \
	--bootappend-live "boot=live persistence components hostname=sleepylinux locales=hu_HU.UTF-8 keyboard-layouts=hu timezone=Europe/Budapest" \
	--image-name "SleepyLinux" \
	--iso-application SleepyLinux \
	--iso-preparer `date +%Y.%m.%d.` \
	--iso-publisher "Sleepy.hu" \
	--memtest none \
	--interactive shell

echo "mc lshw wireshark network-manager net-tools wget openssh-client \
task-xfce-desktop xserver-xorg-core gparted ntfs-3g hfsprogs rsync dosfstools \
partclone clonezilla sshfs nano calamares calamares-settings-debian" > config/package-lists/my.list.chroot
# # #
lb build
