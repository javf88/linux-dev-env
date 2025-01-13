#!/bin/bash
echo "# Downloading resources"
ISO=ubuntu-24.10-live-server-arm64.iso

if [ -f "./$ISO" ]; then
    echo "$ISO exists already."
else
    echo -e "\nFetching $ISO"
    curl -O https://cdimage.ubuntu.com/releases/24.10/release/$ISO
fi

echo -e "Mounting $ISO in ubuntu"
mkdir ubuntu
result=$(hdiutil attach -nomount $ISO)
DISK=$(echo $result | sed "s/ .*//")
mount -t cd9660 $DISK ubuntu

if [ -d ext ]; then
    echo "bootloader extracted already."
else
    echo "Extracting kernel and initrd into ext"
    cp ubuntu/casper/vmlinuz vmlinux.gz
    gzip -d vmlinux.gz

    mkdir ext
    mv vmlinux ext
    cp ubuntu/casper/initrd ext
fi

if [ -d "ext/BlockDevice.dmg" ]; then
    echo "BlockDevide.dmg exists already."
else
    echo "Creating disk image"
    hdiutil create -size 30g -type UDIF ext/BlockDevice.dmg
fi

echo "Unmounting and cleaning the workspace"
umount ubuntu
hdiutil detach $DISK
rm -rf ubuntu
