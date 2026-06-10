import Foundation
import Combine

@MainActor
final class ProgresosViewModel: ObservableObject {
    @Published var progresos: [Progreso] = []
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
            progresos = try await apiClient.list("progresos")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save(_ progreso: Progreso) async -> Bool {
        do {
            let result: Progreso
            if let id = progreso.id {
                result = try await apiClient.update(progreso, at: "progresos", id: id)
                if let index = progresos.firstIndex(where: { $0.id == id }) { progresos[index] = result }
            } else {
                result = try await apiClient.create(progreso, at: "progresos")
                progresos.insert(result, at: 0)
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func delete(_ progreso: Progreso) async {
        guard let id = progreso.id else { return }
        do {
            try await apiClient.delete(at: "progresos", id: id)
            progresos.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
