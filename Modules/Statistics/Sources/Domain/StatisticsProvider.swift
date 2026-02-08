import Foundation
import UserManagement
import UserProgress
import Core

public protocol StatisticsProviding: Sendable {
    func loadUsers() async -> [User]
    func loadSeries(for userId: UUID) async -> StatisticsSeries
}

public struct DefaultStatisticsProvider: StatisticsProviding {
    private let userRepository: UserRepository
    private let resultsStore: UserResultsStore
    private let calculator: StatisticsCalculating

    public init(
        userRepository: UserRepository,
        resultsStore: UserResultsStore,
        calculator: StatisticsCalculating = StatisticsCalculator()
    ) {
        self.userRepository = userRepository
        self.resultsStore = resultsStore
        self.calculator = calculator
    }

    public func loadUsers() async -> [User] {
        await userRepository.loadUsers()
    }

    public func loadSeries(for userId: UUID) async -> StatisticsSeries {
        let reading = await resultsStore.readingResults(for: userId)
        let typing = await resultsStore.typingResults(for: userId)
        return calculator.makeSeries(reading: reading, typing: typing)
    }
}
