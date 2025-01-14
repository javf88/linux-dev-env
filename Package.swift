// This over-engineered setting, without the comment below, swift does not
// compile with v6.0
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "vml",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0")
    ],
    targets: [
        .executableTarget(
            name: "vml",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            resources: [
                .process("vml.entitlements")
            ]
        )
    ]
)

