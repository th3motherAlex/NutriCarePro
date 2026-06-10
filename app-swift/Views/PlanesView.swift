import SwiftUI

struct PlanesView: View {
    @EnvironmentObject private var viewModel: PlanesViewModel
    @EnvironmentObject private var pacientes: PacientesViewModel
    @State private var showNew = false
    @State private var editing: PlanAlimenticio?

    var body: some View {
        NavigationStack {
            ScreenBackground {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        AppHeader(
                            eyebrow: "Planes",
                            title: "Plan nutricional",
                            subtitle: "Menus y metas por paciente",
                            trailingSystemImage: "plus",
                            trailingAction: { showNew = true }
                        )

                        if pacientes.pacientes.isEmpty {
                            StatusChip(title: "Crea un paciente primero", color: ClinicalPalette.warning.opacity(0.5))
                        }

                        if viewModel.planes.isEmpty {
                            EmptyState(title: "Sin planes", detail: "Crea planes asignados a tus pacientes.",
                                       icon: "fork.knife")
                        } else {
                            LazyVStack(spacing: 10) {
                                ForEach(viewModel.planes) { plan in
                                    PlanCard(plan: plan, paciente: patientName(for: plan.pacienteId)) {
                                        editing = plan
                                    } onDelete: {
                                        Task { await viewModel.delete(plan) }
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
                PlanFormView(pacientes: pacientes.pacientes) { await viewModel.save($0) }
            }
            .sheet(item: $editing) { plan in
                PlanFormView(plan: plan, pacientes: pacientes.pacientes) { await viewModel.save($0) }
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

private struct PlanCard: View {
    let plan: PlanAlimenticio
    let paciente: String
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        ClinicalCard(background: ClinicalPalette.surface) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(plan.nombre)
                            .font(.headline)
                            .foregroundStyle(ClinicalPalette.ink)
                        Text(paciente)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(ClinicalPalette.green)
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

                Text(plan.descripcion.isEmpty ? "Sin indicaciones registradas" : plan.descripcion)
                    .font(.caption)
                    .foregroundStyle(ClinicalPalette.mutedInk)
                    .lineLimit(2)

                HStack {
                    StatusChip(title: plan.activo ? "Activo" : "Pausado")
                    if let calories = plan.caloriasObjetivo {
                        StatusChip(title: "\(calories) kcal", color: ClinicalPalette.field)
                    }
                    Spacer()
                    Text(plan.fechaInicio ?? "Sin inicio")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(ClinicalPalette.mutedInk)
                }
            }
        }
    }
}
