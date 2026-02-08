import SwiftUI
import Observation

public struct AccessibilitySettingsView: View {
    @Bindable private var viewModel: AccessibilitySettingsViewModel
    private let onLogout: (() -> Void)?

    public init(viewModel: AccessibilitySettingsViewModel, onLogout: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onLogout = onLogout
    }

    public var body: some View {
        Form {
            Section("Texto") {
                Slider(value: $viewModel.settings.fontScale, in: 0.8...1.6, step: 0.1) {
                    Text("Tamaño de letra")
                }
                Text("Tamaño actual: \(Int(viewModel.settings.fontScale * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Contraste") {
                Toggle("Alto contraste", isOn: $viewModel.settings.highContrast)
            }

            if let onLogout {
                Section("Cuenta") {
                    Button("Cerrar sesión", role: .destructive) { onLogout() }
                        .accessibilityIdentifier("logout_button")
                }
            }
        }
        .padding()
        .onChange(of: viewModel.settings) { _, _ in
            viewModel.save()
        }
        .accessibilityIdentifier("settings_view")
    }
}
