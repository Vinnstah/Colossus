// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Colossus",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "Colossus",
            targets: ["Colossus"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Vinnstah/crypto-service", from: "0.1.2"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", branch: "shared-state-beta"),
        .package(url: "https://github.com/tgrapperon/swift-dependencies-additions", from: "1.0.1"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.2.1"),
    ],
    targets: [
        .target(
            name: "Colossus",
            dependencies: [
                .product(name: "CryptoService", package: "crypto-service"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "DependenciesAdditions", package: "swift-dependencies-additions"),
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),
    ]
)
