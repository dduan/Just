// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Just",
    products: [
        .library(name: "Just", targets: ["Just"])
    ],
    targets: [
        .target(name: "Just"),
        .testTarget(name: "JustTests", dependencies: ["Just"])
    ]
)
