import SwiftUI
import TypingPractice
import ReadingPractice
import AccessibilitySettings
import Statistics
import UserManagement
import StoryManagement
import WordLearning

@MainActor
struct MainTabView: View {
    private let user: User
    private let dependencies: AppDependencies
    private let onLogout: () -> Void

    @State private var typingViewModel: TypingPracticeViewModel
    @State private var readingViewModel: ReadingPracticeViewModel
    @State private var wordLearningViewModel: WordLearningViewModel
    @State private var settingsViewModel: AccessibilitySettingsViewModel
    @State private var statisticsViewModel: StatisticsViewModel
    @State private var storyManagementViewModel: StoryManagementViewModel

    init(user: User, dependencies: AppDependencies, onLogout: @escaping () -> Void) {
        self.user = user
        self.dependencies = dependencies
        self.onLogout = onLogout
        _typingViewModel = State(initialValue: dependencies.makeTypingViewModel(userId: user.id))
        _readingViewModel = State(initialValue: dependencies.makeReadingViewModel(userId: user.id))
        _wordLearningViewModel = State(initialValue: dependencies.makeWordLearningViewModel())
        _settingsViewModel = State(initialValue: dependencies.makeSettingsViewModel())
        _statisticsViewModel = State(initialValue: dependencies.makeStatisticsViewModel())
        _storyManagementViewModel = State(initialValue: dependencies.makeStoryManagementViewModel(createdByUserId: user.id))
    }

    var body: some View {
        NavigationStack {
            TabView {
                TypingPracticeView(viewModel: typingViewModel, settingsViewModel: settingsViewModel)
                    .tabItem { Label("Escritura", systemImage: "keyboard") }
                ReadingPracticeView(viewModel: readingViewModel, settingsViewModel: settingsViewModel)
                    .tabItem { Label("Lectura", systemImage: "book") }
                WordLearningView(viewModel: wordLearningViewModel, settingsViewModel: settingsViewModel)
                    .tabItem { Label("Vocabulario", systemImage: "text.book.closed") }
                AccessibilitySettingsView(viewModel: settingsViewModel)
                    .tabItem { Label("Accesibilidad", systemImage: "figure.walk.circle") }
                if user.role == .tutor {
                    StoryManagementView(viewModel: storyManagementViewModel)
                        .tabItem { Label("Historias", systemImage: "book.closed") }
                    StatisticsView(viewModel: statisticsViewModel)
                        .tabItem { Label("Estadísticas", systemImage: "chart.bar") }
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Cerrar sesión") { onLogout() }
                            .accessibilityIdentifier("profile_logout_button")
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "person.crop.circle")
                            Text(user.displayName)
                        }
                    }
                    .accessibilityIdentifier("profile_menu_button")
                }
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .accessibilityIdentifier("main_tab_view")
    }
}
