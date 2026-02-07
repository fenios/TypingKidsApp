import SwiftUI
import TypingPractice
import ReadingPractice
import AccessibilitySettings

@MainActor
struct ContentView: View {
    @State private var typingViewModel: TypingPracticeViewModel
    @State private var readingViewModel: ReadingPracticeViewModel
    @State private var settingsViewModel: AccessibilitySettingsViewModel

    init(dependencies: AppDependencies) {
        _typingViewModel = State(initialValue: dependencies.typingViewModel)
        _readingViewModel = State(initialValue: dependencies.readingViewModel)
        _settingsViewModel = State(initialValue: dependencies.settingsViewModel)
    }

    var body: some View {
        TabView {
            TypingPracticeView(viewModel: typingViewModel, settingsViewModel: settingsViewModel)
                .tabItem { Label("Escritura", systemImage: "keyboard") }
            ReadingPracticeView(viewModel: readingViewModel, settingsViewModel: settingsViewModel)
                .tabItem { Label("Lectura", systemImage: "book") }
            AccessibilitySettingsView(viewModel: settingsViewModel)
                .tabItem { Label("Accesibilidad", systemImage: "figure.walk.circle") }
        }
        .frame(minWidth: 900, minHeight: 600)
        .accessibilityIdentifier("main_tab_view")
    }
}
