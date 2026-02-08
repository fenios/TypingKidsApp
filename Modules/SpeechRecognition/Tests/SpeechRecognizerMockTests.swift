import XCTest
@testable import SpeechRecognition

final class SpeechRecognizerMockTests: XCTestCase {
    func testMockYieldsTranscripts() async {
        let recognizer = SpeechRecognizerMock()
        let stream = try? await recognizer.startRecognition(locale: Locale(identifier: "es-ES"))
        XCTAssertNotNil(stream)
        var iterator = stream?.makeAsyncIterator()

        await recognizer.push(transcript: "hola")
        let value = try? await iterator?.next()

        XCTAssertEqual(value, "hola")
        await recognizer.stopRecognition()
    }
}
