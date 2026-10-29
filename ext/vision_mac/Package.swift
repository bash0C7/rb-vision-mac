// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "VisionMac",
    platforms: [.macOS(.v27)],
    products: [
        .library(
            name: "VisionMac",
            type: .dynamic,
            targets: ["VisionMac"]
        ),
    ],
    targets: [
        .target(
            name: "VisionMac"
        ),
    ]
)
