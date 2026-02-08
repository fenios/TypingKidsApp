import XCTest
@testable import Statistics
import UserManagement

final class StatisticsViewModelTests: XCTestCase {
    @MainActor
    func testLoadDefaultsToFirstUser() async {
        let userA = User(displayName: "Ana", role: .alumno, pinHash: "", createdAt: .now)
        let userB = User(displayName: "Bruno", role: .alumno, pinHash: "", createdAt: .now)

        let provider = MockStatisticsProvider(users: [userA, userB])
        let viewModel = StatisticsViewModel(provider: provider)

        await viewModel.load()

        XCTAssertEqual(viewModel.selectedUserId, userA.id)
        XCTAssertNotNil(viewModel.series)
    }

    @MainActor
    func testSelectionReloadsSeries() async {
        let userA = User(displayName: "Ana", role: .alumno, pinHash: "", createdAt: .now)
        let userB = User(displayName: "Bruno", role: .alumno, pinHash: "", createdAt: .now)

        let seriesA = StatisticsSeries(wpmPoints: [ChartPoint(date: .now, value: 50)], averageWordTimePoints: [], typingErrorPoints: [])
        let seriesB = StatisticsSeries(wpmPoints: [ChartPoint(date: .now, value: 80)], averageWordTimePoints: [], typingErrorPoints: [])
        let provider = MockStatisticsProvider(users: [userA, userB], seriesByUser: [userA.id: seriesA, userB.id: seriesB])
        let viewModel = StatisticsViewModel(provider: provider)

        await viewModel.load()
        await viewModel.selectUser(userB.id)

        XCTAssertEqual(viewModel.selectedUserId, userB.id)
        XCTAssertEqual(viewModel.series?.wpmPoints.first?.value, 80)
    }
}

private struct MockStatisticsProvider: StatisticsProviding {
    let users: [User]
    let seriesByUser: [UUID: StatisticsSeries]

    init(users: [User], seriesByUser: [UUID: StatisticsSeries] = [:]) {
        self.users = users
        self.seriesByUser = seriesByUser
    }

    func loadUsers() async -> [User] {
        users
    }

    func loadSeries(for userId: UUID) async -> StatisticsSeries {
        seriesByUser[userId] ?? .empty
    }
}
