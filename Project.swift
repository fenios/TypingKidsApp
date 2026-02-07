import ProjectDescription

let organizationName = "TypingKids"
let bundlePrefix = "com.typingkids"
let deploymentTargets: DeploymentTargets = .macOS("14.0")

let baseSettings: SettingsDictionary = [
    "SWIFT_VERSION": "6.0",
    "DEVELOPMENT_TEAM": "",
    "CODE_SIGN_IDENTITY": "-"
]

let project = Project(
    name: "TypingKids",
    organizationName: organizationName,
    settings: .settings(base: baseSettings),
    targets: [
        // Core
        .target(
            name: "Core",
            destinations: .macOS,
            product: .staticFramework,
            bundleId: "\(bundlePrefix).core",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: ["Modules/Core/Sources/**"],
            resources: [],
            dependencies: []
        ),
        .target(
            name: "CoreTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "\(bundlePrefix).core.tests",
            infoPlist: .default,
            sources: ["Modules/Core/Tests/**"],
            dependencies: [.target(name: "Core")]
        ),

        // Persistence
        .target(
            name: "Persistence",
            destinations: .macOS,
            product: .staticFramework,
            bundleId: "\(bundlePrefix).persistence",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: ["Modules/Persistence/Sources/**"],
            resources: [],
            dependencies: [.target(name: "Core")]
        ),
        .target(
            name: "PersistenceTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "\(bundlePrefix).persistence.tests",
            infoPlist: .default,
            sources: ["Modules/Persistence/Tests/**"],
            dependencies: [.target(name: "Persistence")]
        ),

        // Stories
        .target(
            name: "Stories",
            destinations: .macOS,
            product: .staticFramework,
            bundleId: "\(bundlePrefix).stories",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: ["Modules/Stories/Sources/**"],
            resources: ["Modules/Stories/Resources/**"],
            dependencies: [.target(name: "Core")]
        ),
        .target(
            name: "StoriesTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "\(bundlePrefix).stories.tests",
            infoPlist: .default,
            sources: ["Modules/Stories/Tests/**"],
            resources: ["Modules/Stories/Tests/Resources/**"],
            dependencies: [.target(name: "Stories")]
        ),

        // Accessibility Settings
        .target(
            name: "AccessibilitySettings",
            destinations: .macOS,
            product: .staticFramework,
            bundleId: "\(bundlePrefix).accessibility",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: ["Modules/AccessibilitySettings/Sources/**"],
            resources: [],
            dependencies: [.target(name: "Core"), .target(name: "Persistence")]
        ),
        .target(
            name: "AccessibilitySettingsTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "\(bundlePrefix).accessibility.tests",
            infoPlist: .default,
            sources: ["Modules/AccessibilitySettings/Tests/**"],
            dependencies: [.target(name: "AccessibilitySettings")]
        ),

        // Typing Practice
        .target(
            name: "TypingPractice",
            destinations: .macOS,
            product: .staticFramework,
            bundleId: "\(bundlePrefix).typing",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: ["Modules/TypingPractice/Sources/**"],
            resources: [],
            dependencies: [
                .target(name: "Core"),
                .target(name: "Stories"),
                .target(name: "Persistence"),
                .target(name: "AccessibilitySettings")
            ]
        ),
        .target(
            name: "TypingPracticeTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "\(bundlePrefix).typing.tests",
            infoPlist: .default,
            sources: ["Modules/TypingPractice/Tests/**"],
            dependencies: [.target(name: "TypingPractice")]
        ),

        // Reading Practice
        .target(
            name: "ReadingPractice",
            destinations: .macOS,
            product: .staticFramework,
            bundleId: "\(bundlePrefix).reading",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: ["Modules/ReadingPractice/Sources/**"],
            resources: [],
            dependencies: [
                .target(name: "Core"),
                .target(name: "Stories"),
                .target(name: "Persistence"),
                .target(name: "AccessibilitySettings")
            ]
        ),
        .target(
            name: "ReadingPracticeTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "\(bundlePrefix).reading.tests",
            infoPlist: .default,
            sources: ["Modules/ReadingPractice/Tests/**"],
            dependencies: [.target(name: "ReadingPractice")]
        ),

        // App
        .target(
            name: "TypingKidsApp",
            destinations: .macOS,
            product: .app,
            bundleId: "\(bundlePrefix).app",
            deploymentTargets: deploymentTargets,
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "Typing Kids",
                "CFBundleName": "Typing Kids",
                "CFBundleShortVersionString": "1.0.0",
                "CFBundleVersion": "1",
                "LSMinimumSystemVersion": "14.0"
            ]),
            sources: ["App/Sources/**"],
            resources: [],
            dependencies: [
                .target(name: "Core"),
                .target(name: "Stories"),
                .target(name: "TypingPractice"),
                .target(name: "ReadingPractice"),
                .target(name: "AccessibilitySettings"),
                .target(name: "Persistence")
            ]
        ),
        .target(
            name: "TypingKidsAppTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "\(bundlePrefix).app.tests",
            infoPlist: .default,
            sources: ["App/Tests/**"],
            dependencies: [.target(name: "TypingKidsApp")]
        ),
        .target(
            name: "TypingKidsAppUITests",
            destinations: .macOS,
            product: .uiTests,
            bundleId: "\(bundlePrefix).app.uitests",
            infoPlist: .default,
            sources: ["App/UITests/**"],
            dependencies: [.target(name: "TypingKidsApp")]
        )
    ]
)
