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
                .linkedFramework("WebKit"),
            ]
        ),
        .target(
            name: "JarizzCoreTestHelpers",
            dependencies: ["JarizzCore"],
            path: "Tests/JarizzCoreTestHelpers"
        ),
        .testTarget(
            name: "JarizzCoreTests",
            dependencies: ["JarizzCore", "JarizzCoreTestHelpers"],
            path: "Tests/JarizzCoreTests"
        ),
        .testTarget(
            name: "JarizzAcceptanceTests",
            dependencies: ["JarizzCore", "JarizzCoreTestHelpers"],
            path: "Tests/JarizzAcceptanceTests",
            exclude: ["ir"]
        ),
        .testTarget(
            name: "JarizzCorePropertyTests",
            dependencies: ["JarizzCore", "JarizzCoreTestHelpers"],
            path: "Tests/JarizzCorePropertyTests"
        ),
    ]
)
