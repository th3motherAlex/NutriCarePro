import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var session: SessionViewModel
    @StateObject private var pacientes = PacientesViewModel()
    @StateObject private var planes = PlanesViewModel()
    @StateObject private var citas = CitasViewModel()
    @StateObject private var progresos = ProgresosViewModel()

    var body: some View {
        TabView {
            NavigationStack {
                ScreenBackground {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            AppHeader(
                                eyebrow: "Bienvenido",
                                title: session.currentUser?.nombre ?? "Nutriologo",
                                subtitle: "Consulta clinica de hoy",
                                trailingSystemImage: "rectangle.portrait.and.arrow.right",
                                trailingAction: session.logout
                            )

                            CalendarStrip()

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                MetricCard(title: "Pacientes activos", value: pacientes.pacientes.count,
                                           icon: "person.2.fill", color: ClinicalPalette.green)
                                MetricCard(title: "Planes", value: planes.planes.count,
                                           icon: "fork.knife", color: ClinicalPalette.darkGreen)
                                MetricCard(title: "Citas", value: citas.citas.count,
                                           icon: "calendar", color: ClinicalPalette.mutedGreen)
                                MetricCard(title: "Progresos", value: progresos.progresos.count,
                                           icon: "chart.line.uptrend.xyaxis", color: ClinicalPalette.blue)
                            }

                            ClinicalCard(background: ClinicalPalette.surface) {
                                VStack(alignment: .leading, spacing: 14) {
                                    HStack {
                                        Text("Recordatorios")
                                            .font(.headline)
                                            .foregroundStyle(ClinicalPalette.ink)
                                        Spacer()
                                        StatusChip(title: "24 hrs")
                                    }

                                    ReminderRow(icon: "drop.fill", title: "Agua", detail: "Confirmar adherencia del paciente")
                                    ReminderRow(icon: "leaf.fill", title: "Plan", detail: "Revisar menu de seguimiento")
                                    ReminderRow(icon: "calendar.badge.clock", title: "Cita", detail: "Preparar nota de consulta")
                                }
                            }
                        }
                        .padding()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(.hidden, for: .navigationBar)
            }
            .tabItem { Label("Inicio", systemImage: "house.fill") }

            PacientesView()
                .environmentObject(pacientes)
                .tabItem { Label("Pacientes", systemImage: "person.2.fill") }

            PlanesView()
                .environmentObject(planes)
                .environmentObject(pacientes)
                .tabItem { Label("Planes", systemImage: "fork.knife") }

            CitasView()
                .environmentObject(citas)
                .environmentObject(pacientes)
                .tabItem { Label("Consultas", systemImage: "calendar") }

            ProgresoView()
                .environmentObject(progresos)
                .environmentObject(pacientes)
                .tabItem { Label("Perfil", systemImage: "chart.line.uptrend.xyaxis") }
        }
        .tint(ClinicalPalette.lightGreen)
        .toolbarBackground(ClinicalPalette.darkGreen, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
        .task {
            async let pacientesLoad: Void = pacientes.load()
            async let planesLoad: Void = planes.load()
            async let citasLoad: Void = citas.load()
            async let progresosLoad: Void = progresos.load()
            _ = await (pacientesLoad, planesLoad, citasLoad, progresosLoad)
        }
    }
}

private struct CalendarStrip: View {
    private let days = ["LU", "MA", "MI", "JU", "VI", "SA", "DO"]
    private let numbers = ["22", "23", "24", "25", "26", "27", "28"]

    var body: some View {
        ClinicalCard(background: ClinicalPalette.surface) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Mayo 2026")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(ClinicalPalette.ink)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(ClinicalPalette.mutedInk)
                }
                HStack(spacing: 8) {
                    ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                        VStack(spacing: 6) {
                            Text(day)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(ClinicalPalette.mutedInk)
                            Text(numbers[index])
                                .font(.caption.weight(.bold))
                                .foregroundStyle(index == 4 ? ClinicalPalette.darkGreen : ClinicalPalette.ink)
                                .frame(width: 30, height: 30)
                                .background(index == 4 ? ClinicalPalette.lightGreen : .clear, in: Circle())
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

private struct ReminderRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(ClinicalPalette.darkGreen)
                .frame(width: 34, height: 34)
                .background(ClinicalPalette.lightGreen.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(ClinicalPalette.ink)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(ClinicalPalette.mutedInk)
            }
            Spacer()
        }
    }
}
