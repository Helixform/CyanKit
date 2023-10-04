// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CyanKit",
    platforms: [.iOS(.v14), .macOS(.v11), .tvOS(.v14)],
    products: [
        .library(
            name: "CyanKit",
            targets: ["CyanKit"]),
        .library(
            name: "CyanUtils",
            targets: ["CyanUtils"]),
    ],
    targets: [
        .target(name: "CyanExtensions"),
        .target(name: "CyanUtils", dependencies: ["CCyanUtils"]),
        .target(name: "CyanCombine"),
        .target(name: "CyanConcurrency"),
        .target(name: "CyanSwiftUI", dependencies: ["CyanExtensions", "CyanUtils"]),
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
        
        .target(name: "CCyanUtils"),
        
        .testTarget(
            name: "CyanUtilsTests",
            dependencies: ["CyanUtils"]),
        .testTarget(
            name: "CyanConcurrencyTests",
            dependencies: ["CyanConcurrency"])
    ]
)
