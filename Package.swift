// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CyanKit",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "CyanKit",
            targets: ["CyanKit"]),
    ],
    targets: [
        .target(name: "CyanExtensions"),
        .target(name: "CyanUtils"),
        .target(name: "CyanUI", dependencies: ["CyanExtensions"]),
        .target(
            name: "CyanKit",
            dependencies: [
                "CyanExtensions",
                "CyanUtils",
                "CyanUI",
            ]),
    ]
)
