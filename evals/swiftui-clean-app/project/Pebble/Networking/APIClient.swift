import Foundation

enum APIError: Error {
    case badStatus(Int)
    case unauthorized
}

/// Thin client for the Pebble sync backend. All traffic is HTTPS.
struct APIClient {
    static let baseURL = URL(string: "https://api.pebblejournal.app/v1")!

    var sessionToken: String?

    func send<Response: Decodable>(_ path: String, method: String = "GET", body: Encodable? = nil) async throws -> Response {
        var request = URLRequest(url: Self.baseURL.appending(path: path))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let sessionToken {
            request.setValue("Bearer \(sessionToken)", forHTTPHeaderField: "Authorization")
        }
        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.badStatus(-1) }
        if http.statusCode == 401 { throw APIError.unauthorized }
        guard (200..<300).contains(http.statusCode) else { throw APIError.badStatus(http.statusCode) }
        if Response.self == EmptyResponse.self { return EmptyResponse() as! Response }
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

struct EmptyResponse: Decodable {}
