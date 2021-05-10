// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "Hearken",
    products: [
        .library(name: "Hearken", targets: ["Hearken"]),
        .library(name: "HearkenTestKit", targets: ["HearkenTestKit"]),
        .executable(name: "HearkenExample", targets: ["HearkenExample"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.29.0"),
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.43.1"),
        .package(url: "https://github.com/SwiftDocOrg/swift-doc.git", .branch("master"))
    ],
    targets: [
        .target(name: "Hearken", dependencies: [
            .product(name: "NIOHTTP1", package: "swift-nio")
        ]),
        .target(name: "HearkenTestKit", dependencies: ["Hearken"]),
        .executableTarget(name: "HearkenExample", dependencies: ["Hearken"]),
        .testTarget(name: "HearkenTests", dependencies: ["Hearken"]),
        .testTarget(name: "HearkenTestKitTests", dependencies: ["HearkenTestKit"])
    ]
)
