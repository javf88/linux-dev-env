import Foundation
import ArgumentParser

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

        RunLoop.main.run(until: Date.distantFuture)
    }
}
