import Foundation

struct LoginRequest: Codable, Sendable {
    var email: String
    var password: String
}

struct LoginResponse: Codable, Sendable {
    let id: Int
    let nombre: String
    let email: String
    let especialidad: String?
    let mensaje: String
}

struct Paciente: Codable, Identifiable, Hashable, Sendable {
    var id: Int?
    var nombre: String = ""
    var apellido: String = ""
    var email: String = ""
    var telefono: String = ""
    var fechaNacimiento: String?
    var genero: String = ""
    var objetivo: String = ""
    var notas: String = ""
    var nutriologoId: Int?

    var nombreCompleto: String {
        "\(nombre) \(apellido)".trimmingCharacters(in: .whitespaces)
    }
}

struct PlanAlimenticio: Codable, Identifiable, Hashable, Sendable {
    var id: Int?
    var pacienteId: Int?
    var nombre: String = ""
    var descripcion: String = ""
    var caloriasObjetivo: Int?
    var fechaInicio: String?
    var fechaFin: String?
    var activo: Bool = true
}

struct Cita: Codable, Identifiable, Hashable, Sendable {
    var id: Int?
    var pacienteId: Int?
    var fechaHora: String = ""
    var motivo: String = ""
    var estado: String = "PROGRAMADA"
    var notas: String = ""
}

struct Progreso: Codable, Identifiable, Hashable, Sendable {
    var id: Int?
    var pacienteId: Int?
    var fecha: String = ""
    var peso: Decimal?
    var altura: Decimal?
    var porcentajeGrasa: Decimal?
    var cintura: Decimal?
    var observaciones: String = ""
}

enum DateText {
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()

    static let displayDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    static func day(_ date: Date) -> String {
        dayFormatter.string(from: date)
    }

    static func dateTime(_ date: Date) -> String {
        dateTimeFormatter.string(from: date)
    }

    static func parseDay(_ text: String?) -> Date {
        dayFormatter.date(from: text ?? "") ?? Date()
    }

    static func parseDateTime(_ text: String) -> Date {
        dateTimeFormatter.date(from: text) ?? Date()
    }

    static func displayDateTime(_ text: String) -> String {
        displayDateTimeFormatter.string(from: parseDateTime(text))
    }
}
