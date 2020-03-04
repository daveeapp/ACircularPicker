// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ACircularPicker",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "ACircularPicker", targets: ["ACircularPicker"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ACircularPicker",path: "Source"),
        .testTarget(
            name: "ACircularPickerTests",
            dependencies: ["ACircularPicker"]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
