import SwiftUI
import Observation

public struct CreateUserView: View {
    @Bindable private var viewModel: CreateUserViewModel
    private let onCreated: (User) -> Void
    private let onCancel: () -> Void

    public init(
        viewModel: CreateUserViewModel,
        onCreated: @escaping (User) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onCreated = onCreated
        self.onCancel = onCancel
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Datos") {
                    TextField("Nombre", text: $viewModel.displayName)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityIdentifier("create_user_name_field")

                    Picker("Rol", selection: $viewModel.role) {
                        ForEach(UserRole.allCases) { role in
                            Text(role.displayName).tag(role)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("create_user_role_picker")

                    SecureField("PIN (4 dígitos)", text: $viewModel.pin)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityIdentifier("create_user_pin_field")
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Crear usuario")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear") {
                        Task {
                            if let user = await viewModel.createUser() {
                                onCreated(user)
                            }
                        }
                    }
                    .disabled(viewModel.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("create_user_submit_button")
                }
            }
        }
    }
}
