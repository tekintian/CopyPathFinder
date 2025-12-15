// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "CopyPathFinder",
    platforms: [
        .macOS(.v11)
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
            exclude: ["Info.plist"]
        )
    ]
)