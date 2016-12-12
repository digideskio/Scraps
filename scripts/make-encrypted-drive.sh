#!/bin/bash
# -----------------------------------------------------------------------------
# make-encrypted-drive.sh
# -----------------------------------------------------------------------------
# Makes an external drive formatted with LUKS encryption and ext4 filesystem
# 
# Example: $ sudo make-encrypted-drive.sh /dev/sda DriveName
#
# Requires: cryptsetup, pv
#
# :authors: Brennan Novak, 01AEEADB9EED1B5B4280E5B6C4CAA23B0F8C68B2
# :license: BSD license
# :date 21 November 2016
# :version: 0.0.1
# 
# -----------------------------------------------------------------------------

echo "running luksFormat on: $1"
sudo cryptsetup -y -v luksFormat $1

echo "running luksOpen on: $1"
sudo cryptsetup luksOpen $1 $2

echo "formating ext4 filesystem"
sudo mkfs.ext4 /dev/mapper/$2

echo "running luksClose on: $2"
sudo cryptsetup luksClose $2

echo "writing zeros to disk... to monitor run in a separate terminal"
echo "  pv -treb /dev/zero | sudo dd of=/dev/mapper/$2 bs=128M"
echo "-------------------------------------------------------------------------"
sleep 1
sudo dd if=/dev/zero of=/dev/mapper/$2
