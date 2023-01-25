// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UseCaseKit",
    platforms: [.iOS(.v14), .macOS(.v12), .watchOS(.v7), .tvOS(.v14)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "UseCaseKit",
            targets: ["UseCaseKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/realm/SwiftLint.git", revision: "d98fd53"),
        .package(url: "https://github.com/Quick/Quick.git", from: "6.1.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "11.2.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "UseCaseKit",
            dependencies: [],
            plugins: [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]),
        .testTarget(
            name: "UseCaseKitTests",
            dependencies: ["UseCaseKit", "Quick", "Nimble"],
            plugins: [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")])
    ]
)
    
