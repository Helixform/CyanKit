# CyanKit

[![.github/workflows/compile_check.yml](https://github.com/IcyStudio/CyanKit/actions/workflows/compile_check.yml/badge.svg?branch=main)](https://github.com/IcyStudio/CyanKit/actions/workflows/compile_check.yml)

CyanKit is a cross-platform package that contains something we feel useful for app development. Most components may only be suitable for our private use.

## Structure

The package is splited into a few targets with different usages:
Target | Description
--- | ---
CyanKit | An umbrella module exporting all the other targets.
CyanExtensions | Extensions for existing types in Apple frameworks.
CyanUtils | Miscellaneous components that can be used independently.
CyanUI | Flavored views and controls for SwiftUI.

## Getting Started
CyanKit heavily uses [SwiftPM](https://swift.org/package-manager/) as its build tool, so we recommend using that as well. If you want to depend on CyanKit in your own project, it's as simple as adding a `dependencies` clause to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/IcyStudio/CyanKit.git", from: "4.0.0")
]
```

and then adding the appropriate CyanKit module(s) to your target dependencies.
