// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "status-dot-daemon",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "status-dot-daemon",
            path: "Sources/status-dot-daemon"
        ),
    ]
)
