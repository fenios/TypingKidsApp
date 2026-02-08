import SwiftUI
import UserManagement

@MainActor
struct ContentView: View {
    private let dependencies: AppDependencies
    @State private var appViewModel: AppRootViewModel

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _appViewModel = State(initialValue: AppRootViewModel(dependencies: dependencies))
    }

    var body: some View {
        Group {
            if appViewModel.isLoading {
                ProgressView("Cargando...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let user = appViewModel.currentUser {
                MainTabView(
                    user: user,
                    dependencies: dependencies,
                    onLogout: { Task { await appViewModel.logout() } }
                )
                .id(user.id)
            } else {
                LoginView(
                    viewModel: dependencies.makeLoginViewModel(),
                    makeCreateUserViewModel: { dependencies.makeCreateUserViewModel() },
                    onLogin: { user in appViewModel.handleLogin(user) }
                )
            }
        }
        .task { await appViewModel.loadSession() }
    }
}
