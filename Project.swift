import ProjectDescription

let project = Project(
    name: "dailymath",
    targets: [
        .target(
            name: "dailymath",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.dailymath",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            buildableFolders: [
                "Sources",
                "Resources",
            ],
            dependencies: []
        ),
        .target(
            name: "dailymathTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.dailymathTests",
            infoPlist: .default,
            buildableFolders: [
                "Tests"
            ],
            dependencies: [.target(name: "dailymath")]
        ),
    ]
)
