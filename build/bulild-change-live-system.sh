#!/bin/bash

sed -i 's/Live system/SleepyLinux Live/g' /DATA/LIVE/SleepyLinux/binary/boot/grub/grub.cfg
rm /DATA/LIVE/SleepyLinux/.build/binary_iso
cd /DATA/LIVE/SleepyLinux/
lb binary_iso
