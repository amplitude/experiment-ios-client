// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "skylab-ios-client",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_10),
        .tvOS(.v9),
        .watchOS(.v3)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Skylab",
            targets: ["Skylab"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "Amplitude", url: "https://github.com/amplitude/Amplitude-iOS", from: "8.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Skylab",
            dependencies: ["Amplitude"],
            path: "Sources/Skylab",
            exclude: ["Info.plist"]),
        .testTarget(
            name: "SkylabTests",
            dependencies: ["Skylab"],
            path: "Tests/SkylabTests",
            exclude: ["Info.plist"]),
    ]
)
