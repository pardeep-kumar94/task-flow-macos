// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TaskFlow",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "TaskFlow",
            path: "Sources/TaskFlow",
            resources: [
                .copy("Resources/Fonts")
            ],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ]
        )
    ]
)
