// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Demo",
    platforms: [
       .macOS(.v12)
    ],
    targets: [
        .executableTarget(
            name: "Demo",
            path: "Sources"
        ),
    ]
)
