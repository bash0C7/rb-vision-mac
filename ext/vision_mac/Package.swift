// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "VisionMac",
    platforms: [.macOS(.v12)],
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
