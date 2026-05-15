#!/bin/bash

sed -i 's/Live system/SleepyLinux Live/g' /DATA/LIVE/SleepyLinux/binary/boot/grub/grub.cfg
rm /DATA/LIVE/SleepyLinux/*.iso
rm /DATA/LIVE/SleepyLinux/*.md5
rm /DATA/LIVE/SleepyLinux/.build/binary_iso
cd /DATA/LIVE/SleepyLinux/
lb binary_iso
DATUM=`date +%y.%m`; mv SleepyLinux-amd64.hybrid.iso SleepyLinux-$DATUM-amd64.iso; md5sum SleepyLinux-$DATUM-amd64.iso > SleepyLinux-$DATUM-amd64.iso.md5; chown -R majorsza:majorsza SleepyLinux-*
