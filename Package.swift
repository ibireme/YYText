// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "YYText",
    platforms: [.iOS(.v8)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "YYText",
            targets: ["YYText"]),
    ],
    targets: [
        .target(
            name: "YYText",
            path: "YYText",
            cSettings: [
                .headerSearchPath("Component"),
                .headerSearchPath("String"),
                .headerSearchPath("Utility")
            ]
        )
    ]
)
