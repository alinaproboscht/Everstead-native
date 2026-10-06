// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EversteadCore",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "EversteadCore",
            targets: ["EversteadCore"]
        )
    ],
    targets: [
        .target(
            name: "EversteadCore",
            path: "Sources/EversteadCore"
        )
    ]
)
