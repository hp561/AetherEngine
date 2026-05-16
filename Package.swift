// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AetherEngine",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "AetherEngine",
            targets: ["AetherEngine"]
        ),
        // aetherctl product removed: the target uses Foundation.Process
        // which is unavailable on tvOS/iOS, but the executable target
        // was declared without a platform restriction. SPM consumers
        // building for tvOS/iOS were pulled into compiling it and
        // failed with `cannot find 'Process' in scope`. The aetherctl
        // target itself is preserved below so `swift build` on macOS
        // still produces the CLI; only the published product surface
        // changes.
    ],
    dependencies: [
        // Minimal FFmpeg build (avcodec, avformat, avutil, swresample only).
        // No network stack — we use custom AVIO + URLSession for HTTP streams.
        // Resolved over Git rather than a local path so consumers (and
        // Xcode Cloud) can build without a sibling FFmpegBuild checkout.
        .package(url: "https://github.com/superuser404notfound/FFmpegBuild", branch: "main"),
    ],
    targets: [
        .target(
            name: "AetherEngine",
            dependencies: [
                .product(name: "FFmpegBuild", package: "FFmpegBuild"),
            ],
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("AVKit"),
                .linkedFramework("CoreMedia"),
                .linkedFramework("CoreVideo"),
                .linkedFramework("VideoToolbox"),
                .linkedFramework("AudioToolbox"),
            ]
        ),
        .executableTarget(
            name: "aetherctl",
            dependencies: ["AetherEngine"],
            path: "Sources/aetherctl"
        ),
    ]
)
