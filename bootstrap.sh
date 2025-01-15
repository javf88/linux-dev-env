#!/bin/bash

ISO=ubuntu-24.04.1-live-server-arm64.iso

download()
{
    if [ ! -f "./$ISO" ]; then
        echo -e "\nFetching $ISO"
        curl -O https://cdimage.ubuntu.com/releases/24.04.1/release/$ISO
    else
        echo "$ISO exists already."
    fi

    return 0
}

mount_disk()
{
    echo -e "Mounting $ISO in ubuntu"
    mkdir ubuntu
    hdiutil attach -nomount $ISO
    DISK=$(hdiutil info | grep "/dev/disk" | sed "s/s.\t.*//" | tail -n 1)
    mount -t cd9660 $DISK ubuntu

    return 0
}

extract()
{
    echo "Extracting kernel and initrd"
    cp ubuntu/casper/vmlinuz vmlinux.gz
    gzip -d vmlinux.gz
    cp ubuntu/casper/initrd .

    return 0
}

create()
{
    if [ ! -f BlockDevice.dmg ]; then
        echo "Creating disk image"
        hdiutil create -size 30g -type UDIF BlockDevice.dmg
    else
        echo "BlockDevide.dmg exists already."
    fi

    return 0
}

unmount()
{
    echo "Unmounting and cleaning the workspace"
    umount ubuntu
    DISK=$(hdiutil info | grep "/dev/disk" | sed "s/s.\t.*//" | tail -n 1)
    hdiutil detach $DISK
    rm -rf ubuntu

    return 0
}

if [ ! -d ext ]; then
    mkdir ext
    cd ext

    echo "# Downloading resources"
    download
    mount_disk
    extract
    create
    unmount
else
    echo "Repository has already been  initialized"
fi
