#!/bin/bash

SPARSEBUNDLE=/Volumes/macs/cdepaula-mac.sparsebundle

chflags -R nouchg $SPARSEBUNDLE

OUTPUT=`hdiutil attach -nomount -readwrite -noverify -noautofsck "$SPARSEBUNDLE"`

PART=`echo $OUTPUT | grep Apple_HFS | awk print '{$1}'`

fsck_hfs -drfy $PART

#fsck_hfs -p $PART

echo "Change value from 2 to 0"
echo "  <key>VerificationState</key>"
echo "  <integer>0</integer>"
echo "Remove <key>RecoveryBackupDeclinedDate</key> and it's <date> if exists"

read -p "Press enter to continue"

vi “$SPARSEBUNDLE/com.apple.TimeMachine.MachineID.plist”
