import SwiftUI

struct ProgresoFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var progreso: Progreso
    @State private var date: Date
    @State private var peso: String
    @State private var altura: String
    @State private var grasa: String
    @State private var cintura: String
    @State private var isSaving = false
    @State private var formError: String?

    let pacientes: [Paciente]
    let onSave: (Progreso) async -> Bool

    init(progreso: Progreso = Progreso(), pacientes: [Paciente],
         onSave: @escaping (Progreso) async -> Bool) {
        var initial = progreso
        if initial.pacienteId == nil {
            initial.pacienteId = pacientes.first?.id
        }
        _progreso = State(initialValue: initial)
        _date = State(initialValue: DateText.parseDay(progreso.fecha))
        _peso = State(initialValue: progreso.peso?.description ?? "")
        _altura = State(initialValue: progreso.altura?.description ?? "")
        _grasa = State(initialValue: progreso.porcentajeGrasa?.description ?? "")
        _cintura = State(initialValue: progreso.cintura?.description ?? "")
        self.pacientes = pacientes
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ScreenBackground {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        AppHeader(
                            eyebrow: progreso.id == nil ? "Nuevo progreso" : "Editar progreso",
                            title: "Perfil de paciente",
                            subtitle: "Antropometria y avances"
                        )

                        FormSectionCard(title: "Registro") {
                            Picker("Paciente", selection: $progreso.pacienteId) {
                                ForEach(pacientes) { Text($0.nombreCompleto).tag($0.id) }
                            }
                            .tint(ClinicalPalette.darkGreen)
                            .padding(12)
                            .background(ClinicalPalette.field, in: RoundedRectangle(cornerRadius: 10))

                            ClinicalDatePicker(title: "Fecha", selection: $date)
                        }

                        FormSectionCard(title: "Antropometria") {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ClinicalTextField(title: "Peso kg", text: $peso, keyboardType: .decimalPad)
                                ClinicalTextField(title: "Altura cm", text: $altura, keyboardType: .decimalPad)
                                ClinicalTextField(title: "% grasa", text: $grasa, keyboardType: .decimalPad)
                                ClinicalTextField(title: "Cintura cm", text: $cintura, keyboardType: .decimalPad)
                            }
                        }

                        FormSectionCard(title: "Observaciones") {
                            ClinicalTextField(title: "Notas de evolucion", text: $progreso.observaciones, axis: .vertical)
                                .lineLimit(3...7)
                        }

                        if let formError {
                            Text(formError)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.red)
                        }

                        PrimaryActionButton(
                            title: isSaving ? "Guardando..." : "Registrar progreso",
                            systemImage: "chart.line.uptrend.xyaxis",
                            isDisabled: isSaving || peso.isEmpty || progreso.pacienteId == nil
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
        guard let validWeight = Decimal(string: peso), validWeight > 0 else {
            formError = "Ingresa un peso valido."
            return
        }
        progreso.fecha = DateText.day(date)
        progreso.peso = validWeight
        progreso.altura = Decimal(string: altura)
        progreso.porcentajeGrasa = Decimal(string: grasa)
        progreso.cintura = Decimal(string: cintura)
        isSaving = true
        if await onSave(progreso) {
            dismiss()
        } else {
            formError = "No se pudo guardar el progreso."
        }
        isSaving = false
    }
}
