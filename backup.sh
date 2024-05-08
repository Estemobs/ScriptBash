#!/bin/sh
# Mount the disk
sudo mount /dev/sda1 /mnt/usb
echo "Disk mounted."

# Initialize the Restic repository
export RESTIC_REPOSITORY=/mnt/usb/restic-repo
export RESTIC_PASSWORD="yourpassword"
restic init
echo "Restic repository initialized."

# Create a backup of the system
restic backup /dev/mmcblk0
echo "System backup created."

# Unmount the disk
sudo umount /mnt/usb
echo "Disk unmounted."


