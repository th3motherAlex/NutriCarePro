import SwiftUI

struct CitasView: View {
    @EnvironmentObject private var viewModel: CitasViewModel
    @EnvironmentObject private var pacientes: PacientesViewModel
    @State private var showNew = false
    @State private var editing: Cita?

    var body: some View {
        NavigationStack {
            ScreenBackground {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        AppHeader(
                            eyebrow: "Consultas",
                            title: "Agenda clinica",
                            subtitle: "Citas y seguimiento",
                            trailingSystemImage: "plus",
                            trailingAction: { showNew = true }
                        )

                        if pacientes.pacientes.isEmpty {
                            StatusChip(title: "Crea un paciente primero", color: ClinicalPalette.warning.opacity(0.5))
                        }

                        if viewModel.citas.isEmpty {
                            EmptyState(title: "Sin citas", detail: "Agenda consultas y da seguimiento oportuno.",
                                       icon: "calendar.badge.plus")
                        } else {
                            LazyVStack(spacing: 10) {
                                ForEach(viewModel.citas) { cita in
                                    AppointmentCard(cita: cita, paciente: patientName(for: cita.pacienteId)) {
                                        editing = cita
                                    } onDelete: {
                                        Task { await viewModel.delete(cita) }
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
                CitaFormView(pacientes: pacientes.pacientes) { await viewModel.save($0) }
            }
            .sheet(item: $editing) { cita in
                CitaFormView(cita: cita, pacientes: pacientes.pacientes) { await viewModel.save($0) }
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

private struct AppointmentCard: View {
    let cita: Cita
    let paciente: String
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        ClinicalCard(background: ClinicalPalette.surface) {
            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 2) {
                    Text(day)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    Text(month)
                        .font(.caption2.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(width: 54, height: 58)
                .background(ClinicalPalette.green, in: RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 7) {
                    HStack {
                        Text(cita.motivo)
                            .font(.headline)
                            .foregroundStyle(ClinicalPalette.ink)
                        Spacer()
                        StatusChip(title: cita.estado.capitalized)
                    }
                    Text(paciente)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(ClinicalPalette.green)
                    Label(DateText.displayDateTime(cita.fechaHora), systemImage: "clock.fill")
                        .font(.caption)
                        .foregroundStyle(ClinicalPalette.mutedInk)
                }

                Menu {
                    Button("Editar", action: onEdit)
                    Button("Eliminar", role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.headline)
                        .foregroundStyle(ClinicalPalette.darkGreen)
                }
            }
        }
    }

    private var day: String {
        let date = DateText.parseDateTime(cita.fechaHora)
        return Calendar.current.component(.day, from: date).formatted()
    }

    private var month: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "MMM"
        return formatter.string(from: DateText.parseDateTime(cita.fechaHora)).uppercased()
    }
}
