// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TopSpin",
    platforms: [
        .iOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "WatchAppFeature", targets: ["WatchAppFeature"]),
        .library(name: "ActiveMatchFeature", targets: ["ActiveMatchFeature"]),
        .library(name: "AddMatchFeature", targets: ["AddMatchFeature"]),
        .library(name: "AppDelegateFeature", targets: ["AppDelegateFeature"]),
        .library(name: "CloudKitClient", targets: ["CloudKitClient"]),
        .library(name: "CombineHelpers", targets: ["CombineHelpers"]),
        .library(name: "ComposableHelpers", targets: ["ComposableHelpers"]),
        .library(name: "CoreDataModel", targets: ["CoreDataModel"]),
        .library(name: "CoreDataStack", targets: ["CoreDataStack"]),
        .library(name: "DateExtension", targets: ["DateExtension"]),
        .library(name: "DefaultSettingClient", targets: ["DefaultSettingClient"]),
        .library(name: "EmailClient", targets: ["EmailClient"]),
        .library(name: "FileClient", targets: ["FileClient"]),
        .library(name: "HealthKitClient", targets: ["HealthKitClient"]),
        .library(name: "MatchClient", targets: ["MatchClient"]),
        .library(name: "MatchHistoryListFeature", targets: ["MatchHistoryListFeature"]),
        .library(name: "MatchSeriesFeature", targets: ["MatchSeriesFeature"]),
        .library(name: "MatchSettingsClient", targets: ["MatchSettingsClient"]),
        .library(name: "MatchSettingsFeature", targets: ["MatchSettingsFeature"]),
        .library(name: "MatchSummaryDetailFeature", targets: ["MatchSummaryDetailFeature"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "MonthlySummaryListFeature", targets: ["MonthlySummaryListFeature"]),
        .library(name: "Rally", targets: ["Rally"]),
        .library(name: "ShareSheetClient", targets: ["ShareSheetClient"]),
        .library(name: "StoreKitClient", targets: ["StoreKitClient"]),
        .library(name: "SwiftUIHelpers", targets: ["SwiftUIHelpers"]),
        .library(name: "UIApplicationClient", targets: ["UIApplicationClient"]),
        .library(name: "UIUserInterfaceStyleClient", targets: ["UIUserInterfaceStyleClient"]),
        .library(name: "UserDefaultsClient", targets: ["UserDefaultsClient"]),
        .library(name: "UserSettingsFeature", targets: ["UserSettingsFeature"]),
        .library(name: "WatchConnectivityClient", targets: ["WatchConnectivityClient"]),
        .library(name: "WorkoutFeature", targets: ["WorkoutFeature"]),
        .library(name: "World", targets: ["World"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            branch: "concurrency-beta"
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
                "AppDelegateFeature",
                "CloudKitClient",
                "ComposableHelpers",
                "CoreDataStack",
                "DefaultSettingClient",
                "EmailClient",
                "FileClient",
                "MatchClient",
                "MatchHistoryListFeature",
                "MatchSettingsClient",
                "Models",
                "ShareSheetClient",
                "StoreKitClient",
                "SwiftUIHelpers",
                "UIApplicationClient",
                "UIUserInterfaceStyleClient",
                "UserDefaultsClient",
                "UserSettingsFeature",
                "WatchConnectivityClient",
                "World",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "CoreDataModelDescription", package: "core-data-model-description"),
            ]
        ),
        .target(
            name: "WatchAppFeature",
            dependencies: [
                "ActiveMatchFeature",
                "ComposableHelpers",
                "CoreDataStack",
                "DefaultSettingClient",
                "HealthKitClient",
                "MatchClient",
                "MatchSettingsClient",
                "Models",
                "SwiftUIHelpers",
                "UserDefaultsClient",
                "WatchConnectivityClient",
                "WorkoutFeature",
                "World",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "CoreDataModelDescription", package: "core-data-model-description"),
            ]
        ),
        .target(
            name: "ActiveMatchFeature",
            dependencies: [
                "ComposableHelpers",
                "Models",
                "Rally",
                "World",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "AddMatchFeature",
            dependencies: [
                "MatchClient",
                "Models",
                "WatchConnectivityClient",
                "World",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "AppDelegateFeature",
            dependencies: [
                "FileClient",
                "UserSettingsFeature",
                "UIUserInterfaceStyleClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "CloudKitClient",
            dependencies: [
                "CoreDataStack",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "CoreDataModelDescription", package: "core-data-model-description")
            ]
        ),
        .target(
            name: "ComposableHelpers",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "CombineHelpers",
            dependencies: [
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
            name: "CoreDataStack"
        ),
        .target(
            name: "DateExtension",
            dependencies: [
                "World"
            ]
        ),
        .target(
            name: "DefaultSettingClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "EmailClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "FileClient",
            dependencies: [
                "CombineHelpers",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "HealthKitClient",
            dependencies: [
                "World",
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
                "AddMatchFeature",
                "MatchClient",
                "Models",
                "MatchSummaryDetailFeature",
                "MonthlySummaryListFeature",
                "World",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "MatchSeriesFeature",
            dependencies: [
                "ComposableHelpers",
                "Models",
                "Rally",
                "World",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "MatchSettingsClient",
            dependencies: [
                "CoreDataModel",
                "Models",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "MatchSettingsFeature",
            dependencies: [
                "DefaultSettingClient",
                "MatchSettingsClient",
                "Models",
                "SwiftUIHelpers",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "MatchSummaryDetailFeature",
            dependencies: [
                "Models",
                "World",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "Models"
        ),
        .target(
            name: "MonthlySummaryListFeature",
            dependencies: [
                "AddMatchFeature",
                "DateExtension",
                "Models",
                "World",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "Rally"
        ),
        .target(
            name: "ShareSheetClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "StoreKitClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(name: "SwiftUIHelpers"),
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
            name: "UserSettingsFeature",
            dependencies: [
                "CloudKitClient",
                "ComposableHelpers",
                "DefaultSettingClient",
                "EmailClient",
                "FileClient",
                "MatchSettingsClient",
                "MatchSettingsFeature",
                "Models",
                "ShareSheetClient",
                "StoreKitClient",
                "SwiftUIHelpers",
                "UIApplicationClient",
                "UIUserInterfaceStyleClient",
                "UserDefaultsClient",
                "World",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            resources: [
                .process("Resources/")
            ]
        ),
        .target(
            name: "WatchConnectivityClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "WorkoutFeature",
            dependencies: [
                "HealthKitClient",
                "SwiftUIHelpers",
                "World",
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
    .testTarget(
        name: "RallyTests",
        dependencies: [
            "Rally"
        ]
    ),
    .testTarget(
        name: "UserSettingsTests",
        dependencies: [
            "UserSettingsFeature",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ]
    ),
])
