import Foundation
import ArgumentParser
import Virtualization

@main
struct Command: ParsableCommand {
    // Arguments
    @Argument(help: "The unzipped kernel's path")
    var kernel: String

    @Argument(help: "The initial ramdisk's path")
    var initrd: String

    @Argument(help: "The iso image's path")
    var image: String

    @Argument(help: "The disk image's path")
    var disk: String

    // Options
    @Option(name: .long, help: "Number of cpu")
    var cpuCount: Int = 2

    @Option(name: .long, help: "Size in GiB")
    var memorySize: UInt64 = 1

    mutating func run() throws {
        print("Setting up bootloader")
        let bootloader = VZLinuxBootLoader(kernelURL: URL(filePath: kernel))
        bootloader.initialRamdiskURL = URL(filePath: initrd)
        bootloader.commandLine = "console=hvc0 root=/dev/vda1"

        print("Configuring console")
        let input = FileHandle.standardInput
        let output = FileHandle.standardOutput
        var attributes = termios()
        tcgetattr(input.fileDescriptor, &attributes)
        attributes.c_iflag &= ~tcflag_t(ICRNL)
        attributes.c_lflag &= ~tcflag_t(ICANON | ECHO)
        tcsetattr(input.fileDescriptor, TCSANOW, &attributes)

        let serialPortConfig = VZVirtioConsoleDeviceSerialPortConfiguration()
        serialPortConfig.attachment = VZFileHandleSerialPortAttachment(fileHandleForReading: input,
                                                                       fileHandleForWriting: output)
        print("Configuring storage devices")
        let isoImage = try VZDiskImageStorageDeviceAttachment(url: URL(fileURLWithPath: image), readOnly: true)
        let isoDevice = VZVirtioBlockDeviceConfiguration(attachment: isoImage)
        let diskImage = try VZDiskImageStorageDeviceAttachment(url: URL(fileURLWithPath: disk), readOnly:  false)
        let diskDevice = VZVirtioBlockDeviceConfiguration(attachment: diskImage)

        let networkDevice = VZVirtioNetworkDeviceConfiguration()
        networkDevice.attachment = VZNATNetworkDeviceAttachment()

        print("Configuring VM")
        let cfg = VZVirtualMachineConfiguration()
        cfg.cpuCount = self.cpuCount
        cfg.memorySize = self.memorySize * 1024 * 1024 * 1024 // 2 GiB
        cfg.bootLoader = bootloader
        // this mybe extra
//        cfg.memoryBalloonDevices = [VZVirtioTraditionalMemoryBalloonDeviceConfiguration()]
        cfg.storageDevices = [isoDevice, diskDevice]
        cfg.serialPorts = [serialPortConfig]
        cfg.networkDevices = [networkDevice]
        do {
            try cfg.validate()
            print("Virtual machine configuration is valid")

        } catch {
            print("Failed to validate the virtual machine configuration. \(error)")

        }

        let vm = VZVirtualMachine(configuration: cfg)
        vm.start { (result) in
            switch result {
                case .success:
                    print("Starting virtual machine...")
                    break
                case .failure(let error):
                    print("Failed to start the virtual machine. \(error)")
                    break
            }
        }

        RunLoop.main.run(until: Date.distantFuture)
    }
}
