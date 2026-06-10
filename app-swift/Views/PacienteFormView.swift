import SwiftUI

struct PacienteFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var paciente: Paciente
    @State private var nacimiento: Date
    @State private var isSaving = false
    @State private var formError: String?

    let onSave: (Paciente) async -> Bool

    init(paciente: Paciente = Paciente(), onSave: @escaping (Paciente) async -> Bool) {
        _paciente = State(initialValue: paciente)
        _nacimiento = State(initialValue: DateText.parseDay(paciente.fechaNacimiento))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ScreenBackground {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        AppHeader(
                            eyebrow: paciente.id == nil ? "Nuevo paciente" : "Editar paciente",
                            title: "Datos generales",
                            subtitle: "Expediente clinico inicial"
                        )

                        FormSectionCard(title: "Datos personales") {
                            ClinicalTextField(title: "Nombre", text: $paciente.nombre)
                            ClinicalTextField(title: "Apellido", text: $paciente.apellido)
                            ClinicalDatePicker(title: "Fecha de nacimiento", selection: $nacimiento)
                            ClinicalTextField(title: "Genero", text: $paciente.genero)
                        }

                        FormSectionCard(title: "Contacto") {
                            ClinicalTextField(title: "Correo", text: $paciente.email, keyboardType: .emailAddress)
                            ClinicalTextField(title: "Telefono", text: $paciente.telefono, keyboardType: .phonePad)
                        }

                        FormSectionCard(title: "Seguimiento") {
                            ClinicalTextField(title: "Objetivo nutricional", text: $paciente.objetivo)
                            ClinicalTextField(title: "Notas", text: $paciente.notas, axis: .vertical)
                                .lineLimit(3...6)
                        }

                        if let formError {
                            Text(formError)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.red)
                        }

                        PrimaryActionButton(
                            title: isSaving ? "Guardando..." : "Registrar paciente",
                            systemImage: "person.badge.plus",
                            isDisabled: isSaving || paciente.nombre.isEmpty || paciente.apellido.isEmpty
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
        isSaving = true
        paciente.fechaNacimiento = DateText.day(nacimiento)
        if await onSave(paciente) {
            dismiss()
        } else {
            formError = "Revisa los datos o la conexion con el servidor."
        }
        isSaving = false
    }
}
