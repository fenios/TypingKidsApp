import SwiftUI
import Foundation
import UserManagement

#if DEBUG
private struct MockStatisticsProvider: StatisticsProviding {
    let users: [User]
    let seriesByUser: [UUID: StatisticsSeries]

    func loadUsers() async -> [User] {
        users
    }

    func loadSeries(for userId: UUID) async -> StatisticsSeries {
        seriesByUser[userId] ?? .empty
    }
}

private struct StatisticsViewPreview: View {
    @State private var viewModel: StatisticsViewModel

    init() {
        let userA = User(displayName: "Ana", role: .alumno, pinHash: "", createdAt: .now)
        let userB = User(displayName: "Bruno", role: .alumno, pinHash: "", createdAt: .now)

        let points = [
            ChartPoint(date: .now.addingTimeInterval(-86400 * 3), value: 70),
            ChartPoint(date: .now.addingTimeInterval(-86400 * 2), value: 78),
            ChartPoint(date: .now.addingTimeInterval(-86400 * 1), value: 85)
        ]
        let series = StatisticsSeries(
            wpmPoints: points,
            averageWordTimePoints: points.map { ChartPoint(date: $0.date, value: 0.8) },
            typingErrorPoints: points.map { ChartPoint(date: $0.date, value: 2) }
        )

        let provider = MockStatisticsProvider(users: [userA, userB], seriesByUser: [userA.id: series, userB.id: series])
        _viewModel = State(initialValue: StatisticsViewModel(provider: provider))
    }

    var body: some View {
        StatisticsView(viewModel: viewModel)
            .task { await viewModel.load() }
    }
}

#Preview {
    StatisticsViewPreview()
}
#endif
