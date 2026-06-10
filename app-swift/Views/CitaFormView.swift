import SwiftUI

struct CitaFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var cita: Cita
    @State private var appointmentDate: Date
    @State private var isSaving = false
    @State private var formError: String?

    let pacientes: [Paciente]
    let onSave: (Cita) async -> Bool
    private let estados = ["PROGRAMADA", "CONFIRMADA", "COMPLETADA", "CANCELADA"]

    init(cita: Cita = Cita(), pacientes: [Paciente], onSave: @escaping (Cita) async -> Bool) {
        var initial = cita
        if initial.pacienteId == nil {
            initial.pacienteId = pacientes.first?.id
        }
        _cita = State(initialValue: initial)
        _appointmentDate = State(initialValue: cita.fechaHora.isEmpty ? Date() : DateText.parseDateTime(cita.fechaHora))
        self.pacientes = pacientes
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ScreenBackground {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        AppHeader(
                            eyebrow: cita.id == nil ? "Nueva consulta" : "Editar consulta",
                            title: "Info consulta",
                            subtitle: "Agenda y motivo"
                        )

                        FormSectionCard(title: "Consulta") {
                            Picker("Paciente", selection: $cita.pacienteId) {
                                ForEach(pacientes) { Text($0.nombreCompleto).tag($0.id) }
                            }
                            .tint(ClinicalPalette.darkGreen)
                            .padding(12)
                            .background(ClinicalPalette.field, in: RoundedRectangle(cornerRadius: 10))

                            ClinicalDatePicker(title: "Fecha y hora", selection: $appointmentDate, components: [.date, .hourAndMinute])
                            ClinicalTextField(title: "Motivo", text: $cita.motivo)

                            Picker("Estado", selection: $cita.estado) {
                                ForEach(estados, id: \.self) { Text($0.capitalized).tag($0) }
                            }
                            .pickerStyle(.segmented)
                        }

                        FormSectionCard(title: "Notas") {
                            ClinicalTextField(title: "Observaciones de la cita", text: $cita.notas, axis: .vertical)
                                .lineLimit(3...7)
                        }

                        if let formError {
                            Text(formError)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.red)
                        }

                        PrimaryActionButton(
                            title: isSaving ? "Guardando..." : "Registrar consulta",
                            systemImage: "calendar.badge.plus",
                            isDisabled: isSaving || cita.motivo.isEmpty || cita.pacienteId == nil
                        ) {
                            Task { await save() }
                        }
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(ClinicalPalette.darkGreen)
                }
            }
        }
    }

    private func save() async {
        cita.fechaHora = DateText.dateTime(appointmentDate)
        isSaving = true
        if await onSave(cita) {
            dismiss()
        } else {
            formError = "No se pudo guardar la cita."
        }
        isSaving = false
    }
}
