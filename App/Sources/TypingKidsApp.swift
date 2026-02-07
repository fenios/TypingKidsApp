import SwiftUI

@main
@MainActor
struct TypingKidsApp: App {
    private let dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            ContentView(dependencies: dependencies)
        }
        .windowStyle(.titleBar)
    }
}
