// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "jarizz",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "JarizzCore", targets: ["JarizzCore"]),
        .executable(name: "jarizz", targets: ["JarizzApp"]),
    ],
    targets: [
        .target(
            name: "JarizzCore",
            path: "Sources/JarizzCore"
        ),
        .executableTarget(
            name: "JarizzApp",
            dependencies: ["JarizzCore"],
            path: "Sources/JarizzApp",
            exclude: ["Info.plist"],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("Carbon"),
                .linkedFramework("SwiftUI"),
            ]
        ),
        .testTarget(
            name: "JarizzCoreTests",
            dependencies: ["JarizzCore"],
            path: "Tests/JarizzCoreTests"
        ),
        .testTarget(
            name: "JarizzAcceptanceTests",
            dependencies: ["JarizzCore"],
            path: "Tests/JarizzAcceptanceTests",
            exclude: ["ir"]
        ),
        .testTarget(
            name: "JarizzCorePropertyTests",
            dependencies: ["JarizzCore"],
            path: "Tests/JarizzCorePropertyTests"
        ),
    ]
)
