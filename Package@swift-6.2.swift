// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "experiment-ios-client",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13),
        .tvOS(.v12),
        .watchOS(.v4),
        .visionOS(.v1),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Experiment",
            targets: ["Experiment"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/amplitude/analytics-connector-ios.git", from: "1.3.1"),
        .package(url: "https://github.com/amplitude/AmplitudeCore-Swift.git", from: "1.0.12"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Experiment",
            dependencies: [
                .product(name: "AnalyticsConnector", package: "analytics-connector-ios"),
                .product(name: "AmplitudeCoreFramework", package: "AmplitudeCore-Swift"),
            ],
            path: "Sources/Experiment",
            exclude: ["Info.plist"],
            resources: [.copy("PrivacyInfo.xcprivacy")],
            swiftSettings: [.swiftLanguageMode(.v5)]),
        .testTarget(
            name: "ExperimentTests",
            dependencies: ["Experiment"],
            path: "Tests/ExperimentTests",
            exclude: ["Info.plist"]),
    ]
)
