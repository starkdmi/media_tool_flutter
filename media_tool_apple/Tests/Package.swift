// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Tests",
    platforms: [
        .macOS(.v12), .iOS(.v15)
    ],
    targets: [
        .executableTarget(
            name: "Tests",
            path: "Sources"
        ),
    ]
)
