#!/bin/bash


## ACD 
## CIS Level 1 Controls - Sonoma Script ##

## This script bridges the gap between some of our remaining CIS Level 1 Controls for macOS Sonoma ##
## It includes remediations that have not been done through a config profile. ##


CURRENT_USER=`whoami`

## 2.2.1 - Enable macOS Application Firewall
/usr/bin/defaults write /Library/Preferences/com.apple.alf globalstate -int 1

## 2.2.2 - Ensure Firewall Stealth Mode Is Enabled (Automated) 
/usr/bin/defaults write /Library/Preferences/com.apple.alf stealthenabled -int 1

## 2.3.3.3 - Disable Service Message Block Sharing
/bin/launchctl disable system/com.apple.smbd

## 2.3.3.7 - Disable Remote Apple Events
sudo /bin/launchctl disable system/com.apple.AEServer

## 2.6.8 - Require Administrator Password to Modify System-Wide Preferences
authDBs=("system.preferences" "system.preferences.energysaver" "system.preferences.network" "system.preferences.printing" "system.preferences.sharing" "system.preferences.softwareupdate" "system.preferences.startupdisk" "system.preferences.timemachine")

for section in ${authDBs[@]}; do
/usr/bin/security -q authorizationdb read "$section" > "/tmp/$section.plist"
key_value=$(/usr/libexec/PlistBuddy -c "Print :shared" "/tmp/$section.plist" 2>&1)
    if [[ "$key_value" == *"Does Not Exist"* ]]; then
        /usr/libexec/PlistBuddy -c "Add :shared bool false" "/tmp/$section.plist"
    else
        /usr/libexec/PlistBuddy -c "Set :shared false" "/tmp/$section.plist"
    fi
    /usr/bin/security -q authorizationdb write "$section" < "/tmp/$section.plist"
done

## 2.11.1 - Disable Password Hint
for u in $(/usr/bin/dscl . -list /Users UniqueID | /usr/bin/awk '$2 > 500 {print $1}'); do
  /usr/bin/dscl . -delete /Users/$u hint
done

## 2.12.2 - Disable Guest Access to Shared SMB Folders
sudo /usr/sbin/sysadminctl -smbGuestAccess off

## 3.1 - Enable Security Auditing
if [[ ! -e /etc/security/audit_control ]] && [[ -e /etc/security/audit_control.example ]];then
  /bin/cp /etc/security/audit_control.example /etc/security/audit_control
fi

sudo /bin/launchctl enable system/com.apple.auditd
sudo /bin/launchctl bootstrap system /System/Library/LaunchDaemons/com.apple.auditd.plist
sudo /usr/sbin/audit -i

## 3.3 - Configure install.log Retention to 365d
/usr/bin/sed -i '' "s/\* file \/var\/log\/install.log.*/\* file \/var\/log\/install.log format='\$\(\(Time\)\(JZ\)\) \$Host \$\(Sender\)\[\$\(PID\\)\]: \$Message' rotate=utc compress file_max=50M size_only ttl=365/g" /etc/asl/com.apple.install

## 3.4 - Configure Audit Retention to 60d
sudo /usr/bin/sed -i.bak 's/^expire-after.*/expire-after:60d/' /etc/security/audit_control && sudo /usr/sbin/audit -s

## 4.2 - Disable Built-In Web Server
/bin/launchctl disable system/org.apache.httpd

## 4.3 - Disable Network File System Service
/bin/launchctl disable system/com.apple.nfsd

## 5.1.1 - Secure Users Home Folders
IFS=$'\n'
for userDirs in $( /usr/bin/find /System/Volumes/Data/Users -mindepth 1 -maxdepth 1 -type d ! \( -perm 700 -o -perm 711 \) | /usr/bin/grep -v "Shared" | /usr/bin/grep -v "Guest" ); do
  /bin/chmod og-rwx "$userDirs"
done
unset IFS

## 5.6 - Disable Root Login
sudo /usr/bin/dscl . -create /Users/root UserShell /usr/bin/false

## 5.7 - Disable Login to Other User's Active and Locked Sessions
/usr/bin/security authorizationdb write system.login.screensaver "use-login-window-ui"