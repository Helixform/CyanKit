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
        .target(name: "CyanCombine"),
        .target(name: "CyanConcurrency"),
        .target(name: "CyanSwiftUI", dependencies: ["CyanExtensions"]),
        .target(name: "CyanUI", dependencies: ["CyanSwiftUI"]),
        .target(
            name: "CyanKit",
            dependencies: [
                "CyanExtensions",
                "CyanUtils",
                "CyanCombine",
                "CyanConcurrency",
                "CyanSwiftUI",
                "CyanUI",
            ]),
        .testTarget(
            name: "CyanConcurrencyTests",
            dependencies: ["CyanConcurrency"])
    ]
)
