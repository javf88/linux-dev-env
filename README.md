# linux-dev-env
This repository aimes to provide for a development environment for the linux
kernel. It is a simply command-line tool that take a linux-based kernel, i.e.
vmlinuz, and initial ram-disk, i.e. initrd.

## How to build
```
    # To retrieve kernel resources
    chmod +x bootstrap.sh
    ./bootstrap.sh

    # To build the exe
    swift build
    # To codesign for security reasons, very important
    codesign --force --sign - --entitlements Sources/vml.entitlements .build/arm64-apple-macosx/debug/vml
    # To run the vm
    .build/arm64-apple-macosx/debug/vml ext/vmlinux ext/initrd ubuntu-24.10-live-server-arm64.iso ext/BlockDevice.dmg
```
