// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "AdaptiveTabBarController",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "AdaptiveTabBarController",
            targets: ["AdaptiveTabBarController"]
        ),
    ],
    targets: [
        .target(
            name: "AdaptiveTabBarController",
            resources: [
                .process("Assets")
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
