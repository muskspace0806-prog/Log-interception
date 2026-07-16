// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ZWB_LogTap",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ZWB_LogTap",
            targets: ["ZWB_LogTap"]
        )
    ],
    targets: [
        .target(
            name: "ZWB_LogTap",
            path: "ZWB_LogTap/Classes",
            resources: [],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug))
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
