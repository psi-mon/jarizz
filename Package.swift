// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "jarizz",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "JarizzCore", targets: ["JarizzCore"]),
    ],
    targets: [
        .target(
            name: "JarizzCore",
            path: "Sources/JarizzCore"
        ),
        .testTarget(
            name: "JarizzCoreTests",
            dependencies: ["JarizzCore"],
            path: "Tests/JarizzCoreTests"
        ),
        .testTarget(
            name: "AcceptanceTests",
            dependencies: ["JarizzCore"],
            path: "acceptance",
            exclude: ["generator", "build"],
            sources: ["runtime", "generated"]
        ),
        .testTarget(
            name: "JarizzCorePropertyTests",
            dependencies: ["JarizzCore"],
            path: "Tests/JarizzCorePropertyTests"
        ),
    ]
)
