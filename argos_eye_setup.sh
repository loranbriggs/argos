#!/bin/bash
# Setup an Argos Eye Device

if [ $(id -u) -ne 0 ]; then
  echo "Please run as root"
  exit
fi

DEFAULT_HOST=raspberrypi
DEFAULT_USER=pi

apt-get update
apt-get upgrade

echo "Time to configure an Argos Eye Device!!!!!!!"

########################## Change Hostname ###########################
host=$(hostname)

echo "Hostname is named $host"

if [ $host = $DEFAULT_HOST ]; then
  echo "consider renaming to avoid collision of other devieces."
fi

read -p "Enter new hostname (blank to skip): " newHost

if [[ -z "$newHost" ]]; then
  echo "skipping..."
else
  echo "changing hostname..."
  hostname $newHost
  sed -i "s/$host/$newHost/g" /etc/hostname
  sed -i "s/$host/$newHost/g" /etc/hosts
fi

echo "Hostname is $(hostname), moving on...."

########################## Create User  ###########################

egrep "^$DEFAULT_USER" /etc/passwd >/dev/null
if [ $? -eq 0 ]; then
  echo "$DEFAULT_USER username detected on system, consider removing or changing password to improve secruity"
fi

read -p "Would you like to create a new user? (y/n)? " -n 1 -r reply
echo
if [[ $reply =~ ^[Yy]$ ]]; then
  read -p "Enter username : " username
  read -s -p "Enter password : " password
  egrep "^$username" /etc/passwd >/dev/null
  if [ $? -eq 0 ]; then
    echo "$username exists! Continuing as is."
  else
    pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
    useradd -m -g sudo -p $pass $username
    [ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
    # add user to video group
    usermod -a -G video $username
    # add user to sudoers file
    echo "$username ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  fi
fi

########################## Install Motion ###########################

apt-get install -y motion

wget https://raw.githubusercontent.com/loranbriggs/argos/master/motion-eye/motion.conf -O /etc/motion/motion.conf
chmod +r /etc/motion/motion.conf
mkdir -p /var/run/motion
chmod 777 /var/run/motion

# start on boot
sed -i "s/no/yes/g" /etc/default/motion

########################### Configure WiFi ###########################

read -p "Would you like to configure Wifi? (y/n)? " -n 1 -r reply
echo
if [[ $reply =~ ^[Yy]$ ]]; then
  read -p "Network name (ssid) : " ssid
  read -p "Enter password : " pass
  cat <<EOT >> /etc/wpa_supplicant/wpa_supplicant.conf
network={
    ssid="$ssid"
    psk="$pass"
}
EOT
fi

echo "Hostname, user, motion, and wifi configure, reboot and you should be ready to go!"
