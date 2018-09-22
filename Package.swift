// swift-tools-version:4.2

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
