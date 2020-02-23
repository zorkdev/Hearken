// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Hearken",
    products: [
        .library(name: "Hearken", targets: ["Hearken"]),
        .library(name: "HearkenTestKit", targets: ["HearkenTestKit"]),
        .executable(name: "HearkenExample", targets: ["HearkenExample"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.14.0"),
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.39.1")
    ],
    targets: [
        .target(name: "Hearken", dependencies: ["NIOHTTP1"]),
        .target(name: "HearkenTestKit", dependencies: ["Hearken"]),
        .target(name: "HearkenExample", dependencies: ["Hearken"]),
        .testTarget(name: "HearkenTests", dependencies: ["Hearken"]),
        .testTarget(name: "HearkenTestKitTests", dependencies: ["HearkenTestKit"])
    ]
)
