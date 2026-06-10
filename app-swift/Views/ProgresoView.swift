import SwiftUI

struct ProgresoView: View {
    @EnvironmentObject private var viewModel: ProgresosViewModel
    @EnvironmentObject private var pacientes: PacientesViewModel
    @State private var showNew = false
    @State private var editing: Progreso?

    var body: some View {
        NavigationStack {
            ScreenBackground {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        AppHeader(
                            eyebrow: "Perfil",
                            title: "Evolucion del paciente",
                            subtitle: "Mediciones y composicion",
                            trailingSystemImage: "plus",
                            trailingAction: { showNew = true }
                        )

                        if pacientes.pacientes.isEmpty {
                            StatusChip(title: "Crea un paciente primero", color: ClinicalPalette.warning.opacity(0.5))
                        }

                        if viewModel.progresos.isEmpty {
                            EmptyState(title: "Sin mediciones", detail: "Registra peso y medidas del paciente.",
                                       icon: "chart.line.uptrend.xyaxis")
                        } else {
                            LazyVStack(spacing: 10) {
                                ForEach(viewModel.progresos) { progreso in
                                    ProgressCard(progreso: progreso, paciente: patientName(for: progreso.pacienteId)) {
                                        editing = progreso
                                    } onDelete: {
                                        Task { await viewModel.delete(progreso) }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                .refreshable { await viewModel.load() }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showNew) {
                ProgresoFormView(pacientes: pacientes.pacientes) { await viewModel.save($0) }
            }
            .sheet(item: $editing) { progreso in
                ProgresoFormView(progreso: progreso, pacientes: pacientes.pacientes) { await viewModel.save($0) }
            }
            .alert("Error", isPresented: hasError) {
                Button("Aceptar") { viewModel.errorMessage = nil }
            } message: { Text(viewModel.errorMessage ?? "") }
        }
    }

    private func patientName(for id: Int?) -> String {
        pacientes.pacientes.first(where: { $0.id == id })?.nombreCompleto ?? "Paciente #\(id ?? 0)"
    }

    private var hasError: Binding<Bool> {
        Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.errorMessage = nil } })
    }
}

private struct ProgressCard: View {
    let progreso: Progreso
    let paciente: String
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        ClinicalCard(background: ClinicalPalette.surface) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(paciente)
                            .font(.headline)
                            .foregroundStyle(ClinicalPalette.ink)
                        Text(progreso.fecha)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(ClinicalPalette.mutedInk)
                    }
                    Spacer()
                    Menu {
                        Button("Editar", action: onEdit)
                        Button("Eliminar", role: .destructive, action: onDelete)
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.headline)
                            .foregroundStyle(ClinicalPalette.darkGreen)
                    }
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ProgressMetric(title: "Peso", value: progreso.peso, unit: "kg")
                    ProgressMetric(title: "Grasa", value: progreso.porcentajeGrasa, unit: "%")
                    ProgressMetric(title: "Altura", value: progreso.altura, unit: "cm")
                    ProgressMetric(title: "Cintura", value: progreso.cintura, unit: "cm")
                }

                if !progreso.observaciones.isEmpty {
                    Text(progreso.observaciones)
                        .font(.caption)
                        .foregroundStyle(ClinicalPalette.mutedInk)
                        .lineLimit(2)
                }
            }
        }
    }
}

private struct ProgressMetric: View {
    let title: String
    let value: Decimal?
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value?.description ?? "-")
                .font(.headline.weight(.bold))
                .foregroundStyle(ClinicalPalette.darkGreen)
            Text("\(title) \(unit)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(ClinicalPalette.mutedInk)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
