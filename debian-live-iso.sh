#!/bin/bash
DATUM=`date +%Y.%m.%d`
mv SleepyLinux-amd64.hybrid.iso SleepyLinux-$DATUM-amd64.iso
md5sum SleepyLinux-$DATUM-amd64.iso > SleepyLinux-$DATUM-amd64.iso.md5
gpg -s -u majorsza@gmail.com SleepyLinux-$DATUM-amd64.iso
gpg --verify SleepyLinux-$DATUM-amd64.iso.gpg
