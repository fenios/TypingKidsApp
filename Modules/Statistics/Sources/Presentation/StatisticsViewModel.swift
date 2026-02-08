import Foundation
import Observation
import Core
import UserManagement
import UserProgress

@MainActor
@Observable
public final class StatisticsViewModel {
    public private(set) var overall: OverallStats? = nil
    public private(set) var students: [StudentStats] = []
    public private(set) var isLoading: Bool = false

    private let userRepository: UserRepository
    private let resultsStore: UserResultsStore

    public init(userRepository: UserRepository, resultsStore: UserResultsStore) {
        self.userRepository = userRepository
        self.resultsStore = resultsStore
    }

    public func load() async {
        isLoading = true
        let users = await userRepository.loadUsers()
        let alumnos = users.filter { $0.role == .alumno }

        var stats: [StudentStats] = []
        var allTyping: [TypingResult] = []
        var allReading: [ReadingResult] = []

        for user in alumnos {
            let typing = await resultsStore.typingResults(for: user.id)
            let reading = await resultsStore.readingResults(for: user.id)
            allTyping.append(contentsOf: typing)
            allReading.append(contentsOf: reading)
            stats.append(StudentStats(user: user, typing: typing, reading: reading))
        }

        stats.sort { $0.user.displayName.localizedStandardCompare($1.user.displayName) == .orderedAscending }
        students = stats
        overall = OverallStats(typing: allTyping, reading: allReading, studentCount: alumnos.count)
        isLoading = false
    }
}

public struct StudentStats: Identifiable, Equatable {
    public let id: UUID
    public let user: User
    public let typingCount: Int
    public let readingCount: Int
    public let averageTypingErrors: Double
    public let averageTypingTime: TimeInterval
    public let averageReadingTime: TimeInterval
    public let averageReadingWordTime: TimeInterval

    public init(user: User, typing: [TypingResult], reading: [ReadingResult]) {
        self.id = user.id
        self.user = user
        self.typingCount = typing.count
        self.readingCount = reading.count
        self.averageTypingErrors = StudentStats.average(typing.map { Double($0.metrics.errorCount) })
        self.averageTypingTime = StudentStats.average(typing.map { $0.metrics.totalTime })
        self.averageReadingTime = StudentStats.average(reading.map { $0.metrics.totalTime })
        self.averageReadingWordTime = StudentStats.average(reading.map { $0.metrics.averageWordTime })
    }

    private static func average(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }
}

public struct OverallStats: Equatable {
    public let studentCount: Int
    public let typingSessions: Int
    public let readingSessions: Int
    public let averageTypingErrors: Double
    public let averageTypingTime: TimeInterval
    public let averageReadingTime: TimeInterval
    public let averageReadingWordTime: TimeInterval

    public init(typing: [TypingResult], reading: [ReadingResult], studentCount: Int) {
        self.studentCount = studentCount
        self.typingSessions = typing.count
        self.readingSessions = reading.count
        self.averageTypingErrors = OverallStats.average(typing.map { Double($0.metrics.errorCount) })
        self.averageTypingTime = OverallStats.average(typing.map { $0.metrics.totalTime })
        self.averageReadingTime = OverallStats.average(reading.map { $0.metrics.totalTime })
        self.averageReadingWordTime = OverallStats.average(reading.map { $0.metrics.averageWordTime })
    }

    private static func average(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }
}
