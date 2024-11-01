// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BuddyKit",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "BuddyFoundation", targets: ["BuddyFoundation"]),
        .library(name: "BuddyPlatform", targets: ["BuddyPlatform"]),
        .library(name: "BuddyImageKit", targets: ["BuddyImageKit"]),
        .library(name: "BuddyUI", targets: ["BuddyUI"]),
        .library(name: "BuddyKit", targets: ["BuddyKit"]),
    ],
    targets: [
        .target(name: "BuddyFoundation"),
        .target(name: "BuddyPlatform", dependencies: [.target(name: "BuddyFoundation")]),
        .target(name: "BuddyImageKit", dependencies: [.target(name: "BuddyFoundation"), .target(name: "BuddyPlatform")]),
        .target(name: "BuddyUI", dependencies: [.target(name: "BuddyFoundation"), .target(name: "BuddyPlatform")]),
        .target(name: "BuddyKit", dependencies: [
            .target(name: "BuddyFoundation"),
            .target(name: "BuddyUI"),
        ]),
    ]
)
