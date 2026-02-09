# TypingKids (macOS)

A SwiftUI macOS app for children ages 7–10 to learn typing and reading skills in Spanish.

## Tech Stack
- Swift 6 (latest stable)
- SwiftUI only
- Tuist for project generation
- Modular architecture (Clean Architecture + MVVM)
- Local persistence via a file-based key-value store
- Unit tests + UI tests for main flows

## Project Structure
```
.
├── Project.swift
├── Tuist/Config.swift
├── App/
│   ├── Sources/
│   ├── Tests/
│   └── UITests/
└── Modules/
    ├── Core/
    │   ├── Sources/Domain
    │   └── Sources/Support
    ├── Persistence/
    │   └── Sources/Data
    ├── Clipart/
    │   ├── Sources/Domain
    │   ├── Sources/Data
    │   └── Sources/Support
    ├── Stories/
    │   ├── Sources/Domain
    │   ├── Sources/Data
    │   └── Resources/
    ├── AccessibilitySettings/
    │   ├── Sources/Domain
    │   ├── Sources/Data
    │   └── Sources/Presentation
    ├── TypingPractice/
    │   ├── Sources/Domain
    │   └── Sources/Presentation
    ├── ReadingPractice/
    │   ├── Sources/Domain
    │   └── Sources/Presentation
    ├── StoryPersistence/
    │   └── Sources/Data
    ├── StoryManagement/
    │   ├── Sources/Domain
    │   └── Sources/Presentation
    ├── UserManagement/
    │   ├── Sources/Domain
    │   ├── Sources/Data
    │   └── Sources/Presentation
    ├── UserProgress/
    │   ├── Sources/Domain
    │   └── Sources/Data
    ├── Statistics/
    │   └── Sources/Presentation
    ├── WordLearning/
    │   ├── Sources/Domain
    │   ├── Sources/Data
    │   └── Sources/Presentation
    ├── LanguageProcessing/
    │   ├── Sources
    │   └── Tests
    └── SpeechRecognition/
        ├── Sources
        └── Tests
```

## Modules and Boundaries
- **Core** ([README](Modules/Core/README.md)): Metrics, clocks, Spanish ISO keyboard sanitization.
- **Persistence** ([README](Modules/Persistence/README.md)): Local file-based storage and in-memory store for tests.
- **Clipart** ([README](Modules/Clipart/README.md)): Downloading, caching, and decoding clipart images (PNG/SVG).
- **Stories** ([README](Modules/Stories/README.md)): Local JSON repository of Spanish children stories.
- **AccessibilitySettings** ([README](Modules/AccessibilitySettings/README.md)): Font scale + high contrast settings, persisted locally.
- **TypingPractice** ([README](Modules/TypingPractice/README.md)): Typing flow, reaction time, total time, error counting.
- **ReadingPractice** ([README](Modules/ReadingPractice/README.md)): Reading flow with per-word timing and speech-based word matching.
- **LanguageProcessing** ([README](Modules/LanguageProcessing/README.md)): Text normalization, tokenization, and Spanish syllable counting.
- **SpeechRecognition** ([README](Modules/SpeechRecognition/README.md)): On-device speech recognition abstraction + mock.
- **UserManagement** ([README](Modules/UserManagement/README.md)): Local users, roles, PIN login, and session handling.
- **UserProgress** ([README](Modules/UserProgress/README.md)): Per-user storage for typing and reading results.
- **Statistics** ([README](Modules/Statistics/README.md)): Tutor-only progress summaries and per-student stats.
- **StoryPersistence** ([README](Modules/StoryPersistence/README.md)): SwiftData persistence for custom stories.
- **StoryManagement** ([README](Modules/StoryManagement/README.md)): Tutor-only CRUD for custom stories.
- **WordLearning** ([README](Modules/WordLearning/README.md)): Vocabulary practice with clipart images.
- **App**: Composition root + SwiftUI tabs.

## Feature Functionality
- Typing practice: children copy story text, with reaction time, total time, and error metrics. ([TypingPractice](Modules/TypingPractice/README.md))
- Reading practice: timed per-word reading with automatic speech matching. ([ReadingPractice](Modules/ReadingPractice/README.md))
- Reading algorithms: sequential story reading or syllable-filtered words. ([ReadingPractice](Modules/ReadingPractice/README.md))
- Accessibility: adjustable font size and high contrast mode. ([AccessibilitySettings](Modules/AccessibilitySettings/README.md))
- Local stories: bundled Spanish stories for ages 7–10. ([Stories](Modules/Stories/README.md))
- Local persistence: stores settings and session results on disk. ([Persistence](Modules/Persistence/README.md))
- Local login: users with roles (tutor, alumno) and PIN access. ([UserManagement](Modules/UserManagement/README.md))
- Per-user results: typing and reading results are scoped to the active user. ([UserProgress](Modules/UserProgress/README.md))
- Tutor statistics: tutor-only tab with overall and per-student summaries. ([Statistics](Modules/Statistics/README.md))
- Custom stories: tutor-only management with SwiftData persistence and visibility for all users. ([StoryManagement](Modules/StoryManagement/README.md), [StoryPersistence](Modules/StoryPersistence/README.md))
- Vocabulary with clipart: word practice with downloadable images and caching. ([WordLearning](Modules/WordLearning/README.md), [Clipart](Modules/Clipart/README.md))

## Metrics Isolation
All metrics and result models are defined in `Modules/Core/Sources/Domain/` and reused by Typing and Reading features.

## Users and Roles
- Session is required to access the app.
- Tutor can view statistics.
- Alumno can access learning tools only.

## Accessibility
- Font size scaling
- High contrast mode

## Spanish Keyboard (ISO)
Input is sanitized using `SpanishISOKeyboard` to support ñ and accented characters.

## Local Stories
Stories are stored in `Modules/Stories/Resources/stories.json` and loaded via `LocalStoryRepository`.

## Build and Run
1. Install Tuist (if needed).
2. Generate the Xcode project:
   ```bash
   tuist generate
   ```
3. Open the generated Xcode project and run the app.

## Tests
- Unit tests in each module `Tests` folder
- UI tests for main typing and reading flows in `App/UITests`
- UI tests cover login, role-based tabs, and statistics visibility.

Run tests from Xcode or via `xcodebuild`.

## Notes
- SwiftUI only (AppKit not used).
- Modular design for testability and scalability.
- Speech recognition uses on-device processing (Speech framework).
