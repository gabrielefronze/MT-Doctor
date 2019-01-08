#!/bin/bash

echo "I am MT-Doctor, the TimeMachine® Doctor (hopefully you get the reference to Back to the Future...)"
echo "This script tries to recover an Apple® TimeMachine sparsebundle corrupted by (malicious?) networking or power glitches."
echo -e "\nIMPORTANT: for security reasons this script assumes the volume where the sparsebundle file is located is already connected to this machine (wheter it is an external hard disk or a NAS)"

SBBasePath="/Volumes/TM.gfronze"
SBName="Gabrieles MacBook Pro.sparsebundle"
SBFullPath="/Volumes/TM.gfronze/Gabrieles MacBook Pro.sparsebundle"

echo -e "\n** Stopping TimeMachine® service..."
tmutil disable

echo -e "\n** Modifying file flags to unlock the backup file..."
chflags -v nouchg "$SBFullPath"
chflags -v nouchg "$SBFullPath/token"

echo -e "\n** Attaching the sparsebundle as a disk and getting the Apple_HFS device ID..."
HDUtilOutput=`hdiutil attach -nomount -readwrite -noverify -noautofsck /Volumes/TM.gfronze/Gabrieles\ MacBook\ Pro.sparsebundle`
TMDevID=`echo "$HDUtilOutput" | awk '/Apple_HFS/{gsub("Apple_HFSX","");gsub("Apple_HFS","");gsub(" ","");print}'`
NOfAppleHFS=`echo "$HDUtilOutput" | grep -c "Apple_HFS*"`
# if [[ "$NOfAppleHFS" -ne "1" ]]
#     echo "!!! More than one Apple_HFS or Apple_HFSX volumes present. Cannot decide which one to use. Emergency stop."
#     exit 1
# fi
unset NOfAppleHFS
unset HDUtilOutput
echo -e "\n** Device ID is: $TMDevID"

echo -e "\n** Executing repair procedure on sparsebundle image... (this will take some time and 2GB of RAM)"
diskutil repairVolume `echo $TMDevID`

echo -e "\n** Removing backup TimeMachine® .plist outcome..."
rm "$SBFullPath/com.apple.TimeMachine.MachineID.bckup"

echo -e "\n** Editing TimeMachine .plist outcome to reset verification status..."
numl=`grep -n "<key>RecoveryBackupDeclinedDate</key>" "$SBFullPath/com.apple.TimeMachine.MachineID.plist" | cut -c1-1`
mv "$SBFullPath/com.apple.TimeMachine.MachineID.plist" "$SBFullPath/com.apple.TimeMachine.MachineID.emmet"
awk '{gsub(/\<integer\>2\<\/integer\>/,"\t\<integer\>0\<\/integer\>",$1);print}' "$SBFullPath/com.apple.TimeMachine.MachineID.emmet" | sed "${numl}d" |  sed "${numl}d" >> "$SBFullPath/com.apple.TimeMachine.MachineID.plist"
unset numl
diff "$SBFullPath/com.apple.TimeMachine.MachineID.emmet" "$SBFullPath/com.apple.TimeMachine.MachineID.plist"

echo -e "\n** Detaching the TimeMachine® volume"
hdutil detach "$TMDevID"

echo -e "\n** Restarting TimeMachine® service..."
tmutil enable

unset SBBasePath
unset SBName
unset SBFullPath

exit 0
