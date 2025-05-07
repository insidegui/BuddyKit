// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BuddyKit",
    platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8), .tvOS(.v15), .visionOS(.v1)],
    products: [
        .library(name: "BuddyPathKit", targets: ["BuddyPathKit"]),
        .library(name: "BuddyFoundation", targets: ["BuddyFoundation"]),
        .library(name: "BuddyPlatform", targets: ["BuddyPlatform"]),
        .library(name: "BuddyImageKit", targets: ["BuddyImageKit"]),
        .library(name: "BuddySwiftData", targets: ["BuddySwiftData"]),
        .library(name: "BuddyUI", targets: ["BuddyUI"]),
        .library(name: "BuddyKit", targets: ["BuddyKit"]),
    ],
    targets: [
        .target(name: "BuddyPathKit"),
        .target(name: "BuddyFoundation", dependencies: [.target(name: "BuddyPathKit")]),
        .target(name: "BuddyPlatform", dependencies: [.target(name: "BuddyFoundation")]),
        .target(name: "BuddyImageKit", dependencies: [.target(name: "BuddyFoundation"), .target(name: "BuddyPlatform")]),
        .target(name: "BuddySwiftData", dependencies: [.target(name: "BuddyFoundation")]),
        .target(name: "BuddyUI", dependencies: [.target(name: "BuddyFoundation"), .target(name: "BuddyPlatform")]),
        .target(name: "BuddyKitObjC"),
        .target(name: "BuddyKit", dependencies: [
            .target(name: "BuddyFoundation"),
            .target(name: "BuddyUI"),
            .target(name: "BuddyKitObjC"),
        ]),
        .testTarget(name: "BuddyPathKitTests", dependencies: [.target(name: "BuddyPathKit")], path: "Tests"),
    ]
)
