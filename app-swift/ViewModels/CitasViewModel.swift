import Foundation
import Combine

@MainActor
final class CitasViewModel: ObservableObject {
    @Published var citas: [Cita] = []
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            citas = try await apiClient.list("citas")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save(_ cita: Cita) async -> Bool {
        do {
            let result: Cita
            if let id = cita.id {
                result = try await apiClient.update(cita, at: "citas", id: id)
                if let index = citas.firstIndex(where: { $0.id == id }) { citas[index] = result }
            } else {
                result = try await apiClient.create(cita, at: "citas")
                citas.append(result)
            }
            citas.sort { $0.fechaHora < $1.fechaHora }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func delete(_ cita: Cita) async {
        guard let id = cita.id else { return }
        do {
            try await apiClient.delete(at: "citas", id: id)
            citas.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
