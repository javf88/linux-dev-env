.PHONY: all clean

# main recipe
all: build sign runVML

clean:
	rm -rf .build

build:
	swift build -v

sign:	build
	codesign --force --sign - --entitlements Sources/vml.entitlements .build/arm64-apple-macosx/debug/vml

runVML: sign
	.build/arm64-apple-macosx/debug/vml ext/vmlinux ext/initrd ubuntu-24.10-live-server-arm64.iso ext/BlockDevice.dmg