import SwiftUI
import TypingPractice
import ReadingPractice
import AccessibilitySettings
import Statistics
import UserManagement

@MainActor
struct MainTabView: View {
    private let user: User
    private let dependencies: AppDependencies
    private let onLogout: () -> Void

    @State private var typingViewModel: TypingPracticeViewModel
    @State private var readingViewModel: ReadingPracticeViewModel
    @State private var settingsViewModel: AccessibilitySettingsViewModel
    @State private var statisticsViewModel: StatisticsViewModel

    init(user: User, dependencies: AppDependencies, onLogout: @escaping () -> Void) {
        self.user = user
        self.dependencies = dependencies
        self.onLogout = onLogout
        _typingViewModel = State(initialValue: dependencies.makeTypingViewModel(userId: user.id))
        _readingViewModel = State(initialValue: dependencies.makeReadingViewModel(userId: user.id))
        _settingsViewModel = State(initialValue: dependencies.makeSettingsViewModel())
        _statisticsViewModel = State(initialValue: dependencies.makeStatisticsViewModel())
    }

    var body: some View {
        TabView {
            TypingPracticeView(viewModel: typingViewModel, settingsViewModel: settingsViewModel)
                .tabItem { Label("Escritura", systemImage: "keyboard") }
            ReadingPracticeView(viewModel: readingViewModel, settingsViewModel: settingsViewModel)
                .tabItem { Label("Lectura", systemImage: "book") }
            AccessibilitySettingsView(viewModel: settingsViewModel, onLogout: onLogout)
                .tabItem { Label("Accesibilidad", systemImage: "figure.walk.circle") }
            if user.role == .tutor {
                StatisticsView(viewModel: statisticsViewModel)
                    .tabItem { Label("Estadísticas", systemImage: "chart.bar") }
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .accessibilityIdentifier("main_tab_view")
    }
}
