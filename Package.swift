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
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "CloudKitClient", targets: ["CloudKitClient"]),
        .library(name: "CoreDataModel", targets: ["CoreDataModel"]),
        .library(name: "CoreDataStack", targets: ["CoreDataStack"]),
        .library(name: "DefaultSettingClient", targets: ["DefaultSettingClient"]),
        .library(name: "MatchHistoryListFeature", targets: ["MatchHistoryListFeature"]),
        .library(name: "MatchClient", targets: ["MatchClient"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "UIApplicationClient", targets: ["UIApplicationClient"]),
        .library(name: "UIUserInterfaceStyleClient", targets: ["UIUserInterfaceStyleClient"]),
        .library(name: "UserDefaultsClient", targets: ["UserDefaultsClient"]),
        .library(name: "WatchConnectivityClient", targets: ["WatchConnectivityClient"]),
        .library(name: "World", targets: ["World"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "0.28.1"
        ),
        .package(
            url: "https://github.com/willbrandin/core-data-model-description",
            from: "0.0.12"
        ),
        .package(
            name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.9.0"
        )
    ],
    targets: [
        .target(
            name: "AppFeature",
            dependencies: [
                "MatchHistoryListFeature",
                "Models",
                "WatchConnectivityClient",
                "World",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "CoreDataModelDescription", package: "core-data-model-description"),
            ]
        ),
        .target(
            name: "CloudKitClient",
            dependencies: [
                "CoreDataStack",
                .product(name: "CoreDataModelDescription", package: "core-data-model-description")
            ]
        ),
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
            name: "DefaultSettingClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
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
                "MatchClient",
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
            name: "UIApplicationClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "UIUserInterfaceStyleClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "UserDefaultsClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "WatchConnectivityClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "World",
            dependencies: []
        )
    ]
)

package.targets.append(contentsOf: [
    
])
