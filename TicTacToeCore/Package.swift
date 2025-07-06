// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TicTacToeCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TicTacToeCore",
            targets: ["TicTacToeCore"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TicTacToeCore",
            dependencies: [],
            resources: [
                .process("ColorPalette.xcassets"),
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "TicTacToeCoreTests",
            dependencies: ["TicTacToeCore"]
        ),
    ]
)
