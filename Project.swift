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

        // Language Processing
        .target(
            name: "LanguageProcessing",
            destinations: .macOS,
            product: .staticFramework,
            bundleId: "\(bundlePrefix).languageprocessing",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: ["Modules/LanguageProcessing/Sources/**"],
            resources: [],
            dependencies: []
        ),
        .target(
            name: "LanguageProcessingTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "\(bundlePrefix).languageprocessing.tests",
            infoPlist: .default,
            sources: ["Modules/LanguageProcessing/Tests/**"],
            dependencies: [.target(name: "LanguageProcessing")]
        ),

        // Speech Recognition
        .target(
            name: "SpeechRecognition",
            destinations: .macOS,
            product: .staticFramework,
            bundleId: "\(bundlePrefix).speechrecognition",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: ["Modules/SpeechRecognition/Sources/**"],
            resources: [],
            dependencies: [
                .sdk(name: "Speech", type: .framework, status: .required),
                .sdk(name: "AVFoundation", type: .framework, status: .required)
            ]
        ),
        .target(
            name: "SpeechRecognitionTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "\(bundlePrefix).speechrecognition.tests",
            infoPlist: .default,
            sources: ["Modules/SpeechRecognition/Tests/**"],
            dependencies: [.target(name: "SpeechRecognition")]
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

        // User Management
        .target(
            name: "UserManagement",
            destinations: .macOS,
            product: .staticFramework,
            bundleId: "\(bundlePrefix).usermanagement",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: ["Modules/UserManagement/Sources/**"],
            resources: [],
            dependencies: [.target(name: "Persistence")]
        ),

        // User Progress
        .target(
            name: "UserProgress",
            destinations: .macOS,
            product: .staticFramework,
            bundleId: "\(bundlePrefix).userprogress",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: ["Modules/UserProgress/Sources/**"],
            resources: [],
            dependencies: [.target(name: "Core"), .target(name: "Persistence")]
        ),

        // Statistics
        .target(
            name: "Statistics",
            destinations: .macOS,
            product: .staticFramework,
            bundleId: "\(bundlePrefix).statistics",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: ["Modules/Statistics/Sources/**"],
            resources: [],
            dependencies: [
                .target(name: "Core"),
                .target(name: "UserManagement"),
                .target(name: "UserProgress")
            ]
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
                .target(name: "AccessibilitySettings"),
                .target(name: "UserProgress")
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
                .target(name: "AccessibilitySettings"),
                .target(name: "LanguageProcessing"),
                .target(name: "SpeechRecognition"),
                .target(name: "UserProgress")
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
                "LSMinimumSystemVersion": "14.0",
                "NSSpeechRecognitionUsageDescription": "Necesitamos acceder al reconocimiento de voz para validar la lectura.",
                "NSMicrophoneUsageDescription": "Necesitamos usar el micrófono para escuchar la lectura."
            ]),
            sources: ["App/Sources/**"],
            resources: [],
            dependencies: [
                .target(name: "Core"),
                .target(name: "Stories"),
                .target(name: "TypingPractice"),
                .target(name: "ReadingPractice"),
                .target(name: "AccessibilitySettings"),
                .target(name: "Persistence"),
                .target(name: "SpeechRecognition"),
                .target(name: "LanguageProcessing"),
                .target(name: "UserManagement"),
                .target(name: "UserProgress"),
                .target(name: "Statistics")
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
