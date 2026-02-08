import Foundation
import Observation
import UserManagement
import UserProgress

@MainActor
@Observable
public final class StatisticsViewModel {
    public private(set) var users: [User] = []
    public var selectedUserId: UUID? = nil
    public private(set) var series: StatisticsSeries? = nil
    public private(set) var isLoading: Bool = false

    private let provider: StatisticsProviding

    public init(provider: StatisticsProviding) {
        self.provider = provider
    }

    public convenience init(userRepository: UserRepository, resultsStore: UserResultsStore) {
        self.init(provider: DefaultStatisticsProvider(userRepository: userRepository, resultsStore: resultsStore))
    }

    public func load() async {
        isLoading = true
        let loadedUsers = await provider.loadUsers()
        users = loadedUsers.sorted { $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending }

        if selectedUserId == nil {
            selectedUserId = users.first?.id
        }

        await reloadSeries()
        isLoading = false
    }

    public func selectUser(_ id: UUID?) async {
        selectedUserId = id
        await reloadSeries()
    }

    public func reloadSeries() async {
        guard let id = selectedUserId else {
            series = nil
            return
        }
        series = await provider.loadSeries(for: id)
    }

    public var selectedUser: User? {
        guard let id = selectedUserId else { return nil }
        return users.first { $0.id == id }
    }
}
