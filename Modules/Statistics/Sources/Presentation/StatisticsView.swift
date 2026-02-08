import SwiftUI
import Observation

public struct StatisticsView: View {
    @Bindable private var viewModel: StatisticsViewModel

    public init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Estadísticas")
        }
        .task { await viewModel.load() }
        .accessibilityIdentifier("statistics_view")
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Cargando estadísticas...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.overall == nil && viewModel.students.isEmpty {
            Text("Aún no hay datos para mostrar.")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                if let overall = viewModel.overall {
                    Section("Resumen general") {
                        StatRow(title: "Alumnos", value: "\(overall.studentCount)")
                        StatRow(title: "Sesiones de escritura", value: "\(overall.typingSessions)")
                        StatRow(title: "Sesiones de lectura", value: "\(overall.readingSessions)")
                        StatRow(title: "Promedio de errores", value: formatNumber(overall.averageTypingErrors))
                        StatRow(title: "Tiempo escritura", value: formatTime(overall.averageTypingTime))
                        StatRow(title: "Tiempo lectura", value: formatTime(overall.averageReadingTime))
                        StatRow(title: "Tiempo por palabra", value: formatTime(overall.averageReadingWordTime))
                    }
                }

                Section("Alumnos") {
                    if viewModel.students.isEmpty {
                        Text("No hay alumnos registrados.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.students) { student in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(student.user.displayName)
                                    .font(.headline)
                                StatRow(title: "Sesiones escritura", value: "\(student.typingCount)")
                                StatRow(title: "Sesiones lectura", value: "\(student.readingCount)")
                                StatRow(title: "Errores promedio", value: formatNumber(student.averageTypingErrors))
                                StatRow(title: "Tiempo escritura", value: formatTime(student.averageTypingTime))
                                StatRow(title: "Tiempo lectura", value: formatTime(student.averageReadingTime))
                                StatRow(title: "Tiempo por palabra", value: formatTime(student.averageReadingWordTime))
                            }
                            .padding(.vertical, 4)
                            .accessibilityElement(children: .contain)
                            .accessibilityIdentifier("statistics_student_\(student.id.uuidString)")
                        }
                    }
                }
            }
        }
    }

    private func formatTime(_ value: TimeInterval) -> String {
        "\(formatNumber(value)) s"
    }

    private func formatNumber(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(2)))
    }
}

private struct StatRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}
