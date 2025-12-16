// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "CopyPathFinder",
    defaultLocalization: "zh-Hans",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(
            name: "CopyPathFinder",
            targets: ["CopyPathFinder"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CopyPathFinder",
            dependencies: [],
            exclude: ["Info.plist"],
            resources: [
                .process("Resources")
            ]
        )
    ]
)