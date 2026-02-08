import SwiftUI
import Observation
import Charts

public struct StatisticsView: View {
    @Bindable private var viewModel: StatisticsViewModel

    public init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    content
                }
                .padding()
            }
            .navigationTitle("Estadísticas")
        }
        .task { await viewModel.load() }
        .animation(.snappy, value: viewModel.series)
        .accessibilityIdentifier("statistics_view")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progreso por usuario")
                .font(.title2)
                .bold()
            userPicker
        }
    }

    @ViewBuilder
    private var userPicker: some View {
        if viewModel.users.isEmpty {
            Text("No hay usuarios para mostrar.")
                .foregroundStyle(.secondary)
        } else {
            let picker = Picker("Usuario", selection: selectionBinding) {
                ForEach(viewModel.users) { user in
                    Text(user.displayName).tag(Optional(user.id))
                }
            }
            .accessibilityIdentifier("statistics_user_picker")

            if viewModel.users.count <= 3 {
                picker.pickerStyle(.segmented)
            } else {
                picker.pickerStyle(.menu)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Cargando estadísticas...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.series?.isEmpty != false {
            ContentUnavailableView(
                "Sin datos",
                systemImage: "chart.bar.xaxis",
                description: Text("Registra sesiones para ver el progreso.")
            )
            .frame(maxWidth: .infinity, minHeight: 300)
        } else if let series = viewModel.series {
            VStack(spacing: 16) {
                chartCard(title: "Palabras por minuto (WPM)") {
                    Chart(series.wpmPoints) { point in
                        LineMark(
                            x: .value("Fecha", point.date),
                            y: .value("WPM", point.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(by: .value("Serie", "WPM"))

                        PointMark(
                            x: .value("Fecha", point.date),
                            y: .value("WPM", point.value)
                        )
                        .foregroundStyle(by: .value("Serie", "WPM"))
                    }
                    .chartXAxisLabel("Fecha")
                    .chartYAxisLabel("WPM")
                    .chartLegend(position: .bottom, alignment: .leading)
                }

                chartCard(title: "Tiempo promedio por palabra") {
                    Chart(series.averageWordTimePoints) { point in
                        AreaMark(
                            x: .value("Fecha", point.date),
                            y: .value("Segundos", point.value)
                        )
                        .foregroundStyle(.blue.gradient.opacity(0.25))

                        LineMark(
                            x: .value("Fecha", point.date),
                            y: .value("Segundos", point.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(by: .value("Serie", "Tiempo por palabra"))
                    }
                    .chartXAxisLabel("Fecha")
                    .chartYAxisLabel("Segundos")
                    .chartLegend(position: .bottom, alignment: .leading)
                }

                chartCard(title: "Errores de escritura") {
                    Chart(series.typingErrorPoints) { point in
                        BarMark(
                            x: .value("Fecha", point.date),
                            y: .value("Errores", point.value)
                        )
                        .foregroundStyle(by: .value("Serie", "Errores"))
                    }
                    .chartXAxisLabel("Fecha")
                    .chartYAxisLabel("Errores")
                    .chartLegend(position: .bottom, alignment: .leading)
                }
            }
        }
    }

    private func chartCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content()
                .frame(height: 220)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color(.windowBackgroundColor), Color(.windowBackgroundColor).opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.gray.opacity(0.2), lineWidth: 1)
        )
    }

    private var selectionBinding: Binding<UUID?> {
        Binding(
            get: { viewModel.selectedUserId },
            set: { newValue in
                Task { await viewModel.selectUser(newValue) }
            }
        )
    }
}
