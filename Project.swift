import ProjectDescription

let project = Project(
    name: "DailyMath",
    organizationName: "Inminente",
    packages: [
        // Descomentar cuando se añada Supabase:
        // .remote(url: "https://github.com/supabase-community/supabase-swift",
        //         requirement: .upToNextMajor(from: "2.0.0"))
    ],
    settings: .settings(
        base: [
            "DEVELOPMENT_TEAM": "68K85UB3R3",
            "SWIFT_VERSION": "5.0",
            "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
            "SWIFT_APPROACHABLE_CONCURRENCY": "YES",
            "SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY": "YES",
        ]
    ),
    targets: [

        // MARK: - App
        .target(
            name: "DailyMath",
            destinations: .iOS,
            product: .app,
            bundleId: "Inminente.DailyMath",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .extendingDefault(with: [
                "UIApplicationSupportsIndirectInputEvents": .boolean(true),
                "UILaunchScreen": .dictionary([:]),
                "UISupportedInterfaceOrientations": .array([
                    .string("UIInterfaceOrientationPortrait"),
                    .string("UIInterfaceOrientationLandscapeLeft"),
                    .string("UIInterfaceOrientationLandscapeRight"),
                ]),
                "UISupportedInterfaceOrientations~ipad": .array([
                    .string("UIInterfaceOrientationPortrait"),
                    .string("UIInterfaceOrientationPortraitUpsideDown"),
                    .string("UIInterfaceOrientationLandscapeLeft"),
                    .string("UIInterfaceOrientationLandscapeRight"),
                ]),
            ]),
            sources: [
                "dailymath/Sources/**/*.swift",
            ],
            resources: [
                "dailymath/Resources/**",
            ],
            dependencies: [
                .sdk(name: "Vision", type: .framework),
            ],
            settings: .settings(
                base: [
                    "CURRENT_PROJECT_VERSION": "1",
                    "MARKETING_VERSION": "1.0",
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                    "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
                    "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": "YES",
                    "GENERATE_INFOPLIST_FILE": "YES",
                    "ENABLE_PREVIEWS": "YES",
                    "SWIFT_EMIT_LOC_STRINGS": "YES",
                    "LOCALIZATION_PREFERS_STRING_CATALOGS": "YES",
                    "STRING_CATALOG_GENERATE_SYMBOLS": "YES",
                    "TARGETED_DEVICE_FAMILY": "1,2",
                    "CODE_SIGN_STYLE": "Automatic",
                    "LD_RUNPATH_SEARCH_PATHS": ["$(inherited)", "@executable_path/Frameworks"],
                ],
                debug: [
                    "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
                    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG $(inherited)",
                    "DEBUG_INFORMATION_FORMAT": "dwarf",
                    "GCC_OPTIMIZATION_LEVEL": "0",
                    "ONLY_ACTIVE_ARCH": "YES",
                    "MTL_ENABLE_DEBUG_INFO": "INCLUDE_SOURCE",
                    "ENABLE_TESTABILITY": "YES",
                ],
                release: [
                    "SWIFT_OPTIMIZATION_LEVEL": "-O",
                    "SWIFT_COMPILATION_MODE": "wholemodule",
                    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                    "MTL_ENABLE_DEBUG_INFO": "NO",
                    "VALIDATE_PRODUCT": "YES",
                    "ENABLE_NS_ASSERTIONS": "NO",
                ]
            )
        ),

        // MARK: - Unit Tests
        .target(
            name: "DailyMathTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "Inminente.DailyMathTests",
            deploymentTargets: .iOS("26.0"),
            sources: ["dailymath/Tests/**/*.swift"],
            dependencies: [.target(name: "DailyMath")],
            settings: .settings(
                base: [
                    "CURRENT_PROJECT_VERSION": "1",
                    "MARKETING_VERSION": "1.0",
                    "TARGETED_DEVICE_FAMILY": "1,2",
                    "CODE_SIGN_STYLE": "Automatic",
                    "SWIFT_EMIT_LOC_STRINGS": "NO",
                    "STRING_CATALOG_GENERATE_SYMBOLS": "NO",
                    "BUNDLE_LOADER": "$(TEST_HOST)",
                    "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/DailyMath.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/DailyMath",
                ]
            )
        ),

        // MARK: - UI Tests
        .target(
            name: "DailyMathUITests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: "Inminente.DailyMathUITests",
            deploymentTargets: .iOS("26.0"),
            sources: ["DailyMathUITests/**/*.swift"],
            dependencies: [.target(name: "DailyMath")],
            settings: .settings(
                base: [
                    "CURRENT_PROJECT_VERSION": "1",
                    "MARKETING_VERSION": "1.0",
                    "TARGETED_DEVICE_FAMILY": "1,2",
                    "CODE_SIGN_STYLE": "Automatic",
                    "SWIFT_EMIT_LOC_STRINGS": "NO",
                    "STRING_CATALOG_GENERATE_SYMBOLS": "NO",
                    "TEST_TARGET_NAME": "DailyMath",
                ]
            )
        ),
    ]
)
