import Foundation
import Combine

@MainActor
final class PacientesViewModel: ObservableObject {
    @Published var pacientes: [Paciente] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            pacientes = try await apiClient.list("pacientes")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save(_ paciente: Paciente) async -> Bool {
        do {
            if let id = paciente.id {
                let updated = try await apiClient.update(paciente, at: "pacientes", id: id)
                replace(updated)
            } else {
                let created = try await apiClient.create(paciente, at: "pacientes")
                pacientes.append(created)
                pacientes.sort { $0.nombreCompleto < $1.nombreCompleto }
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func delete(_ paciente: Paciente) async {
        guard let id = paciente.id else { return }
        do {
            try await apiClient.delete(at: "pacientes", id: id)
            pacientes.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func replace(_ paciente: Paciente) {
        if let index = pacientes.firstIndex(where: { $0.id == paciente.id }) {
            pacientes[index] = paciente
        }
    }
}
