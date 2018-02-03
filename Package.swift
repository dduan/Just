// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Just",
    products: [
        .library(name: "Just", targets: ["Just"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "Just", dependencies: []),
        .testTarget(name: "JustTests", dependencies: ["Just"])
    ]
)
