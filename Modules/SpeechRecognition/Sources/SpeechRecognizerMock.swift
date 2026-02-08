import Foundation

public actor SpeechRecognizerMock: SpeechRecognizer {
    public var authorizationStatus: SpeechRecognizerAuthorizationStatus
    private var continuation: AsyncThrowingStream<String, Error>.Continuation?

    public init(authorizationStatus: SpeechRecognizerAuthorizationStatus = .authorized) {
        self.authorizationStatus = authorizationStatus
    }

    public func requestAuthorization() async -> SpeechRecognizerAuthorizationStatus {
        authorizationStatus
    }

    public func startRecognition(locale: Locale) async throws -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            self.continuation = continuation
        }
    }

    public func stopRecognition() async {
        continuation?.finish()
        continuation = nil
    }

    public func push(transcript: String) async {
        continuation?.yield(transcript)
    }

    public func fail(with error: SpeechRecognizerError) async {
        continuation?.finish(throwing: error)
        continuation = nil
    }
}
