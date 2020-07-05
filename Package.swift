// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Tunisia",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "TunisiaKit", targets: ["TunisiaKit"]),
        .executable(
            name: "tunisia",
            targets: ["tunisia"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/Carthage/Carthage", .exact("0.34.0")),
        .package(url: "https://github.com/kareman/SwiftShell", from: "5.0.1"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.2.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.0.0"),
        .package(url: "https://github.com/sharplet/Regex.git", from: "2.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "tunisia",
            dependencies: ["TunisiaKit"]
        ),
        .target(
            name: "TunisiaKit",
            dependencies: [
                .product(name: "CarthageKit", package: "Carthage"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "XCDBLD",
                "SwiftShell",
                "Rainbow",
                "Regex"
            ]
        ),
        .testTarget(name: "TunisiaTests",
                    dependencies: ["TunisiaKit"]
        )
    ]
)
