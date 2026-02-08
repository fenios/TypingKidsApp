import Foundation
import Core
import Persistence

public actor DefaultUserResultsStore: UserResultsStore {
    private let store: KeyValueStore
    private let typingKey = "typing_results_by_user"
    private let readingKey = "reading_results_by_user"

    public init(store: KeyValueStore) {
        self.store = store
    }

    public func saveTypingResult(_ result: TypingResult, for userId: UUID) async {
        var all = (try? store.get([UUID: [TypingResult]].self, forKey: typingKey)) ?? [:]
        var list = all[userId] ?? []
        list.append(result)
        all[userId] = list
        try? store.set(all, forKey: typingKey)
    }

    public func saveReadingResult(_ result: ReadingResult, for userId: UUID) async {
        var all = (try? store.get([UUID: [ReadingResult]].self, forKey: readingKey)) ?? [:]
        var list = all[userId] ?? []
        list.append(result)
        all[userId] = list
        try? store.set(all, forKey: readingKey)
    }

    public func typingResults(for userId: UUID) async -> [TypingResult] {
        let all = (try? store.get([UUID: [TypingResult]].self, forKey: typingKey)) ?? [:]
        return all[userId] ?? []
    }

    public func readingResults(for userId: UUID) async -> [ReadingResult] {
        let all = (try? store.get([UUID: [ReadingResult]].self, forKey: readingKey)) ?? [:]
        return all[userId] ?? []
    }

    public func typingResultsByUser() async -> [UUID: [TypingResult]] {
        (try? store.get([UUID: [TypingResult]].self, forKey: typingKey)) ?? [:]
    }

    public func readingResultsByUser() async -> [UUID: [ReadingResult]] {
        (try? store.get([UUID: [ReadingResult]].self, forKey: readingKey)) ?? [:]
    }
}
