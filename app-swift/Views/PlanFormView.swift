import SwiftUI

struct PlanFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var plan: PlanAlimenticio
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var calories = ""
    @State private var formError: String?
    @State private var isSaving = false

    let pacientes: [Paciente]
    let onSave: (PlanAlimenticio) async -> Bool

    init(plan: PlanAlimenticio = PlanAlimenticio(), pacientes: [Paciente],
         onSave: @escaping (PlanAlimenticio) async -> Bool) {
        var initial = plan
        if initial.pacienteId == nil {
            initial.pacienteId = pacientes.first?.id
        }
        _plan = State(initialValue: initial)
        _startDate = State(initialValue: DateText.parseDay(plan.fechaInicio))
        _endDate = State(initialValue: DateText.parseDay(plan.fechaFin))
        _calories = State(initialValue: plan.caloriasObjetivo.map(String.init) ?? "")
        self.pacientes = pacientes
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ScreenBackground {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        AppHeader(
                            eyebrow: plan.id == nil ? "Nuevo plan" : "Editar plan",
                            title: "Plan nutricional",
                            subtitle: "Metas e indicaciones"
                        )

                        FormSectionCard(title: "Asignacion") {
                            Picker("Paciente", selection: $plan.pacienteId) {
                                ForEach(pacientes) { paciente in
                                    Text(paciente.nombreCompleto).tag(paciente.id)
                                }
                            }
                            .tint(ClinicalPalette.darkGreen)
                            .padding(12)
                            .background(ClinicalPalette.field, in: RoundedRectangle(cornerRadius: 10))

                            ClinicalTextField(title: "Nombre del plan", text: $plan.nombre)
                            ClinicalTextField(title: "Calorias objetivo", text: $calories, keyboardType: .numberPad)
                        }

                        FormSectionCard(title: "Vigencia") {
                            ClinicalDatePicker(title: "Inicio", selection: $startDate)
                            ClinicalDatePicker(title: "Fin", selection: $endDate)
                            Toggle("Plan activo", isOn: $plan.activo)
                                .font(.subheadline.weight(.semibold))
                                .tint(ClinicalPalette.green)
                        }

                        FormSectionCard(title: "Indicaciones") {
                            ClinicalTextField(title: "Descripcion del plan", text: $plan.descripcion, axis: .vertical)
                                .lineLimit(4...8)
                        }

                        if let formError {
                            Text(formError)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.red)
                        }

                        PrimaryActionButton(
                            title: isSaving ? "Guardando..." : "Guardar plan",
                            systemImage: "fork.knife",
                            isDisabled: isSaving || plan.nombre.isEmpty || plan.pacienteId == nil
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
        guard endDate >= startDate else {
            formError = "La fecha final no puede ser anterior al inicio."
            return
        }
        plan.fechaInicio = DateText.day(startDate)
        plan.fechaFin = DateText.day(endDate)
        plan.caloriasObjetivo = Int(calories)
        isSaving = true
        if await onSave(plan) {
            dismiss()
        } else {
            formError = "No se pudo guardar el plan."
        }
        isSaving = false
    }
}
