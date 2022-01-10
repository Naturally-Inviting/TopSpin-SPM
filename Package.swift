// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TopSpin",
    platforms: [
        .iOS(.v15),
        .watchOS(.v8),
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "CoreDataModel", targets: ["CoreDataModel"]),
        .library(name: "CoreDataStack", targets: ["CoreDataStack"]),
        .library(name: "MatchHistoryListFeature", targets: ["MatchHistoryListFeature"]),
        .library(name: "MatchClient", targets: ["MatchClient"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "World", targets: ["World"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "0.28.1"
        ),
        .package(
            url: "https://github.com/dmytro-anokhin/core-data-model-description",
            from: "0.0.11"
        ),
        .package(
            name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.9.0"
        )
    ],
    targets: [
        .target(
            name: "CoreDataModel",
            dependencies: [
                "CoreDataStack",
                "Models",
                "World",
                .product(name: "CoreDataModelDescription", package: "core-data-model-description")
            ]
        ),
        .target(
            name: "CoreDataStack",
            dependencies: [
            ]
        ),
        .target(
            name: "MatchClient",
            dependencies: [
                "CoreDataModel",
                "Models",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "MatchHistoryListFeature",
            dependencies: [
                "Models",
                "World",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "Models",
            dependencies: []
        ),
        .target(
            name: "World",
            dependencies: []
        )
    ]
)

package.targets.append(contentsOf: [
    
])
