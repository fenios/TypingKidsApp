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
    ├── LanguageProcessing/
    │   ├── Sources
    │   └── Tests
    └── SpeechRecognition/
        ├── Sources
        └── Tests
```

## Modules and Boundaries
- **Core**: Metrics, clocks, Spanish ISO keyboard sanitization.
- **Persistence**: Local file-based storage and in-memory store for tests.
- **Stories**: Local JSON repository of Spanish children stories.
- **AccessibilitySettings**: Font scale + high contrast settings, persisted locally.
- **TypingPractice**: Typing flow, reaction time, total time, error counting.
- **ReadingPractice**: Reading flow with per-word timing and speech-based word matching.
- **LanguageProcessing**: Text normalization, tokenization, and Spanish syllable counting.
- **SpeechRecognition**: On-device speech recognition abstraction + mock.
- **App**: Composition root + SwiftUI tabs.

## Feature Functionality
- Typing practice: children copy story text, with reaction time, total time, and error metrics.
- Reading practice: timed per-word reading with automatic speech matching.
- Reading algorithms: sequential story reading or syllable-filtered words.
- Accessibility: adjustable font size and high contrast mode.
- Local stories: bundled Spanish stories for ages 7–10.
- Local persistence: stores settings and session results on disk.

## Metrics Isolation
All metrics are defined in `Modules/Core/Sources/Domain/Metrics.swift` and reused by Typing and Reading features.

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

Run tests from Xcode or via `xcodebuild`.

## Notes
- SwiftUI only (AppKit not used).
- Modular design for testability and scalability.
- Speech recognition uses on-device processing (Speech framework).
