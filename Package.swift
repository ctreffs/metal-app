// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "MetalApp",
    platforms: [
        .macOS(.v10_11),
        .iOS(.v11),
        .tvOS(.v11)
    ],
    products: [
        .executable(name: "MetalApp_Cmd",
                    targets: ["MetalApp_Cmd"])
    ],
    targets: [
        .target(name: "MetalApp"),
        .target(name: "MetalApp_Cmd",
                dependencies: ["MetalApp"])
    ]
)
