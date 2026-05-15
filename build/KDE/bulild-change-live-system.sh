#!/bin/bash

sed -i 's/Live system/SleepyLinux Live (KDE)/g' /DATA/LIVE/SleepyLinux-KDE/binary/boot/grub/grub.cfg
rm /DATA/LIVE/SleepyLinux-KDE/*.iso
rm /DATA/LIVE/SleepyLinux-KDE/*.md5
rm /DATA/LIVE/SleepyLinux-KDE/.build/binary_iso
cd /DATA/LIVE/SleepyLinux-KDE/
lb binary_iso
DATUM=`date +%y.%m`; mv SleepyLinux-KDE-amd64.hybrid.iso SleepyLinux-KDE-$DATUM-amd64.iso; md5sum SleepyLinux-KDE-$DATUM-amd64.iso > SleepyLinux-KDE-$DATUM-amd64.iso.md5; chown -R majorsza:majorsza SleepyLinux-KDE-*
