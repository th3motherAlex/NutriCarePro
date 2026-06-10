import Foundation
import Combine

@MainActor
final class SessionViewModel: ObservableObject {
    @Published var email = "admin@nutricarepro.com"
    @Published var password = "admin123"
    @Published var currentUser: LoginResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func login() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            currentUser = try await apiClient.login(LoginRequest(email: email, password: password))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logout() {
        currentUser = nil
        password = ""
        errorMessage = nil
    }
}
