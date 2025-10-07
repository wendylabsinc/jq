// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "JQSwift",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "JQSwift",
            targets: ["JQSwift"]
        ),
    ],
    targets: [
        .target(
            name: "Cjq",
            dependencies: [],
            cSettings: [
                .define("_GNU_SOURCE", .when(platforms: [.linux])),
                .define("HAVE_MEMMEM"),
                .headerSearchPath("include"),
            ],
            linkerSettings: [
                .linkedLibrary("m", .when(platforms: [.linux]))
            ]
        ),
        .target(
            name: "JQSwift",
            dependencies: ["Cjq"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "JQSwiftTests",
            dependencies: ["JQSwift"]
        ),
    ]
)
