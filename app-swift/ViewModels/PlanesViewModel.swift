import Foundation
import Combine

@MainActor
final class PlanesViewModel: ObservableObject {
    @Published var planes: [PlanAlimenticio] = []
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
            planes = try await apiClient.list("planes")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save(_ plan: PlanAlimenticio) async -> Bool {
        do {
            let result: PlanAlimenticio
            if let id = plan.id {
                result = try await apiClient.update(plan, at: "planes", id: id)
                if let index = planes.firstIndex(where: { $0.id == id }) { planes[index] = result }
            } else {
                result = try await apiClient.create(plan, at: "planes")
                planes.insert(result, at: 0)
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func delete(_ plan: PlanAlimenticio) async {
        guard let id = plan.id else { return }
        do {
            try await apiClient.delete(at: "planes", id: id)
            planes.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
