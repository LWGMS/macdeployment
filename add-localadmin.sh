#! /bin/sh

# ---------------------------------------------
# create local administrative account on a macOS device
#
# add PWD value before running
# ---------------------------------------------

. /etc/rc.common

PWD=

LAST_ID=`dscl . -list /Users UniqueID | awk '{print $2}' | sort -n | tail -1`
NEXT_ID=$((LAST_ID + 1))
ADMIN_USERNAME=localadmin

if [ -z $PWD ]
then
  echo "missing password variable value (set PWD= in script)"
  exit
fi

echo "running $ADMIN_USERNAME creation script"

# ---------------------------------------------
# Create local administrative user
# ---------------------------------------------

dscl . create /Users/$ADMIN_USERNAME
dscl . create /Users/$ADMIN_USERNAME RealName "Administrative Account"
dscl . create /Users/$ADMIN_USERNAME hint ""
#dscl . create /Users/$ADMIN_USERNAME picture "/Path/To/Picture.png"
dscl . passwd /Users/$ADMIN_USERNAME $PWD
dscl . create /Users/$ADMIN_USERNAME UniqueID $NEXT_ID
dscl . create /Users/$ADMIN_USERNAME PrimaryGroupID 80
dscl . create /Users/$ADMIN_USERNAME UserShell /bin/bash
dscl . create /Users/$ADMIN_USERNAME NFSHomeDirectory /Users/$ADMIN_USERNAME
dscl . create /Users/$ADMIN_USERNAME IsHidden 1
cp -R /System/Library/User\ Template/English.lproj /Users/$ADMIN_USERNAME

# ---------------------------------------------
# Add ssh public key
# ---------------------------------------------

mkdir /Users/$ADMIN_USERNAME/.ssh
touch /Users/$ADMIN_USERNAME/.ssh/authorized_keys
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbwN7/VEIvbg/TfYZZsrV6OxJCeaJEGNS2HxgAEdG/A admin-lwgms-2019-31-01" >> /Users/$ADMIN_USERNAME/.ssh/authorized_keys
chown -R $ADMIN_USERNAME:staff /Users/$ADMIN_USERNAME
chmod 700 /Users/$ADMIN_USERNAME/.ssh
chmod 644 /Users/$ADMIN_USERNAME/.ssh/authorized_keys

# ---------------------------------------------
# Configure and enable remote key auth ssh
# ---------------------------------------------

echo -e "\n\n#Managed Remote Access\nPermitRootLogin no\nPasswordAuthentication no" >> /etc/ssh/sshd_config
systemsetup -setremotelogin on

