import SwiftUI
import Observation

public struct LoginView: View {
    @Bindable private var viewModel: LoginViewModel
    private let onLogin: (User) -> Void
    private let makeCreateUserViewModel: () -> CreateUserViewModel
    @State private var showingCreate = false

    public init(
        viewModel: LoginViewModel,
        makeCreateUserViewModel: @escaping () -> CreateUserViewModel,
        onLogin: @escaping (User) -> Void
    ) {
        self.viewModel = viewModel
        self.makeCreateUserViewModel = makeCreateUserViewModel
        self.onLogin = onLogin
    }

    public var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Iniciar sesión")
                    .font(.title2)
                    .bold()

                if viewModel.users.isEmpty {
                    Text("No hay usuarios. Crea el primero para continuar.")
                        .foregroundStyle(.secondary)
                } else {
                    Picker("Usuario", selection: $viewModel.selectedUser) {
                        ForEach(viewModel.users) { user in
                            Text(user.displayName).tag(Optional(user))
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("login_user_picker")

                    SecureField("PIN (4 dígitos)", text: $viewModel.pin)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityIdentifier("login_pin_field")
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .accessibilityIdentifier("login_error_text")
                }

                HStack(spacing: 12) {
                    Button("Iniciar sesión") {
                        Task {
                            if let user = await viewModel.login() {
                                onLogin(user)
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.users.isEmpty)
                    .accessibilityIdentifier("login_button")

                    Button("Crear usuario") {
                        showingCreate = true
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("create_user_button")
                }

                Spacer()
            }
            .padding()
            .frame(maxWidth: 420, alignment: .leading)
            .task { await viewModel.loadUsers() }
            .sheet(isPresented: $showingCreate) {
                CreateUserView(
                    viewModel: makeCreateUserViewModel(),
                    onCreated: { user in
                        onLogin(user)
                        showingCreate = false
                    },
                    onCancel: { showingCreate = false }
                )
            }
            .navigationTitle("Typing Kids")
        }
        .accessibilityIdentifier("login_view")
    }
}
