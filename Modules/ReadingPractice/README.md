# ReadingPractice Module

## Purpose
Reading practice flow that measures time per word and validates spoken words using on-device speech recognition.

## Responsibilities
- Reading session lifecycle and per-word timing.
- Algorithm selection (sequential story or syllable-filtered words).
- Speech recognition integration and word matching.
- Persist reading results per user.

## Key Types
- `ReadingResult`, `ReadingSessionState`
- `ReadingAlgorithm`, `ReadingAlgorithmOption`
- `ReadingPracticeViewModel`
- `ReadingPracticeView`

## Dependencies
- Core
- Stories
- AccessibilitySettings
- LanguageProcessing
- SpeechRecognition
- UserProgress
