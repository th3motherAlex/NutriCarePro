import SwiftUI

struct PacientesView: View {
    @EnvironmentObject private var viewModel: PacientesViewModel
    @State private var showNew = false
    @State private var editing: Paciente?

    var body: some View {
        NavigationStack {
            ScreenBackground {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        AppHeader(
                            eyebrow: "Pacientes",
                            title: "Seguimiento activo",
                            subtitle: "\(viewModel.pacientes.count) expedientes",
                            trailingSystemImage: "plus",
                            trailingAction: { showNew = true }
                        )

                        SearchPill(text: "Buscar paciente")

                        if viewModel.isLoading && viewModel.pacientes.isEmpty {
                            ProgressView("Cargando pacientes...")
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)
                        } else if viewModel.pacientes.isEmpty {
                            EmptyState(title: "Sin pacientes", detail: "Registra el primer paciente para iniciar.",
                                       icon: "person.crop.circle.badge.plus")
                        } else {
                            LazyVStack(spacing: 10) {
                                ForEach(viewModel.pacientes) { paciente in
                                    PatientCard(paciente: paciente) {
                                        editing = paciente
                                    } onDelete: {
                                        Task { await viewModel.delete(paciente) }
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
                PacienteFormView { paciente in await viewModel.save(paciente) }
            }
            .sheet(item: $editing) { paciente in
                PacienteFormView(paciente: paciente) { edited in await viewModel.save(edited) }
            }
            .alert("No se pudo completar la operacion", isPresented: hasError) {
                Button("Aceptar") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private var hasError: Binding<Bool> {
        Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.errorMessage = nil } })
    }
}

private struct PatientCard: View {
    let paciente: Paciente
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        ClinicalCard(background: ClinicalPalette.surface) {
            HStack(alignment: .top, spacing: 12) {
                Text(initials)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(ClinicalPalette.green, in: Circle())

                VStack(alignment: .leading, spacing: 7) {
                    HStack {
                        Text(paciente.nombreCompleto)
                            .font(.headline)
                            .foregroundStyle(ClinicalPalette.ink)
                        Spacer()
                        StatusChip(title: "Activo")
                    }
                    Text(paciente.objetivo.isEmpty ? "Pendiente de objetivo" : paciente.objetivo)
                        .font(.subheadline)
                        .foregroundStyle(ClinicalPalette.mutedInk)
                    HStack(spacing: 8) {
                        if !paciente.telefono.isEmpty {
                            Label(paciente.telefono, systemImage: "phone.fill")
                        }
                        if !paciente.email.isEmpty {
                            Label("Correo", systemImage: "envelope.fill")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(ClinicalPalette.green)
                }

                Menu {
                    Button("Editar", action: onEdit)
                    Button("Eliminar", role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.headline)
                        .foregroundStyle(ClinicalPalette.darkGreen)
                        .padding(.top, 2)
                }
            }
        }
    }

    private var initials: String {
        let first = paciente.nombre.first.map(String.init) ?? "P"
        let last = paciente.apellido.first.map(String.init) ?? ""
        return "\(first)\(last)".uppercased()
    }
}
