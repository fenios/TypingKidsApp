# SpeechRecognition Module

## Purpose
Provide a reusable, on-device speech recognition interface for macOS. The module abstracts the Speech framework and exposes a testable protocol.

## Key Types
- `SpeechRecognizer`: protocol for authorization and streaming transcriptions.
- `SystemSpeechRecognizer`: Speech framework implementation (on-device recognition).
- `SpeechRecognizerMock`: test double for unit and UI tests.

## Usage
Inject `SpeechRecognizer` into feature modules. Use `startRecognition` to receive an `AsyncStream<String>` of transcripts and compare against expected words.
