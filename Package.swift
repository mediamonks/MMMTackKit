// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "MMMTackKit",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "MMMTackKit",
            targets: ["MMMTackKit"]
		)
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MMMTackKit",
            dependencies: [],
            path: "Sources"
		),
        .testTarget(
            name: "MMMTackKitTests",
            dependencies: ["MMMTackKit"],
            path: "Tests"
		)
    ]
)
