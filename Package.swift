// swift-tools-version:4.2
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
        .package(url: "https://github.com/Carthage/Carthage", .branch("master")),
        .package(url: "https://github.com/Carthage/Commandant.git", .exact("0.16.0")),
        .package(url: "https://github.com/thoughtbot/Curry.git", from: "4.0.2"),
        .package(url: "https://github.com/jdhealy/PrettyColors.git", from: "5.0.2"),
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
                "CarthageKit",
                "carthage",
                "Commandant",
                "Curry",
                "PrettyColors"
            ]
        )
    ],
    swiftLanguageVersions: [.v4_2]
)
