import Foundation
import Core

public protocol UserResultsStore: Sendable {
    func saveTypingResult(_ result: TypingResult, for userId: UUID) async
    func saveReadingResult(_ result: ReadingResult, for userId: UUID) async

    func typingResults(for userId: UUID) async -> [TypingResult]
    func readingResults(for userId: UUID) async -> [ReadingResult]

    func typingResultsByUser() async -> [UUID: [TypingResult]]
    func readingResultsByUser() async -> [UUID: [ReadingResult]]
}
