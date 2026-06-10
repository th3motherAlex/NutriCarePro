import Foundation

struct ServerErrorResponse: Codable, Sendable {
    let message: String?
}

enum APIClientError: LocalizedError {
    case invalidURL
    case invalidResponse
    case server(String)
    case connection(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "La direccion del servidor no es valida."
        case .invalidResponse:
            return "El servidor envio una respuesta no valida."
        case .server(let message):
            return message
        case .connection(let message):
            return "No fue posible conectar con la API: \(message)"
        }
    }
}

final class APIClient: Sendable {
    static let shared = APIClient()

    private let session: URLSession
    private let baseURL: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(session: URLSession = .shared) {
        self.session = session
        let configured = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String
        self.baseURL = URL(string: configured ?? "http://localhost:8080/api")!
    }

    func login(_ credentials: LoginRequest) async throws -> LoginResponse {
        try await request(path: "auth/login", method: "POST", body: credentials)
    }

    func list<T: Decodable & Sendable>(_ path: String) async throws -> [T] {
        try await request(path: path, method: "GET", bodyData: nil)
    }

    func create<T: Codable & Sendable>(_ value: T, at path: String) async throws -> T {
        try await request(path: path, method: "POST", body: value)
    }

    func update<T: Codable & Sendable>(_ value: T, at path: String, id: Int) async throws -> T {
        try await request(path: "\(path)/\(id)", method: "PUT", body: value)
    }

    func delete(at path: String, id: Int) async throws {
        let _: EmptyResponse = try await request(path: "\(path)/\(id)", method: "DELETE", bodyData: nil)
    }

    private func request<Response: Decodable & Sendable, Body: Encodable>(
        path: String,
        method: String,
        body: Body
    ) async throws -> Response {
        try await request(path: path, method: method, bodyData: encoder.encode(body))
    }

    private func request<Response: Decodable & Sendable>(
        path: String,
        method: String,
        bodyData: Data?
    ) async throws -> Response {
        guard let url = URL(string: path, relativeTo: baseURL.appendingPathComponent("")) else {
            throw APIClientError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = bodyData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIClientError.invalidResponse
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                let serverMessage = try? decoder.decode(ServerErrorResponse.self, from: data).message
                throw APIClientError.server(serverMessage ?? "Error HTTP \(httpResponse.statusCode).")
            }
            if Response.self == EmptyResponse.self && data.isEmpty {
                return EmptyResponse() as! Response
            }
            return try decoder.decode(Response.self, from: data)
        } catch let error as APIClientError {
            throw error
        } catch {
            throw APIClientError.connection(error.localizedDescription)
        }
    }
}

private struct EmptyResponse: Codable, Sendable {
}
