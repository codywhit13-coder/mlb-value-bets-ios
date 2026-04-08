//
//  APIClient.swift
//  MLBValueBets
//
//  Async/await wrapper over URLSession for the Render-hosted backend.
//  Features:
//    - Injects `Authorization: Bearer <jwt>` from the current Supabase session
//    - Retries once on 401 after forcing a session refresh
//    - Decodes JSON with `.convertFromSnakeCase`
//    - Returns typed APIErrors for predictable error handling in the UI
//

import Foundation

actor APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let baseURL: URL

    init(session: URLSession = .shared, baseURL: URL = Config.apiBaseURL) {
        self.session = session
        self.baseURL = baseURL
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    // MARK: - Public API

    /// GET request expecting a JSON response of type T.
    /// Set `authenticated = false` for public endpoints (performance, games).
    func get<T: Decodable>(
        _ path: String,
        as type: T.Type,
        authenticated: Bool = true
    ) async throws -> T {
        try await request(path: path, method: "GET", body: nil, authenticated: authenticated)
    }

    /// POST request with optional JSON body.
    func post<T: Decodable, Body: Encodable>(
        _ path: String,
        body: Body?,
        as type: T.Type,
        authenticated: Bool = true
    ) async throws -> T {
        let encoded: Data?
        if let body = body {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            encoded = try encoder.encode(body)
        } else {
            encoded = nil
        }
        return try await request(path: path, method: "POST", body: encoded, authenticated: authenticated)
    }

    // MARK: - Core request + retry

    private func request<T: Decodable>(
        path: String,
        method: String,
        body: Data?,
        authenticated: Bool,
        isRetry: Bool = false
    ) async throws -> T {
        var url = baseURL
        if let appended = URL(string: path, relativeTo: baseURL) {
            url = appended
        }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        if body != nil {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        req.httpBody = body

        if authenticated {
            guard let token = await SupabaseManager.shared.currentAccessToken() else {
                throw APIError.notAuthenticated
            }
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: req)
        } catch {
            throw APIError.transport(error.localizedDescription)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.badResponse
        }

        // Handle status codes
        switch http.statusCode {
        case 200..<300:
            break
        case 401:
            // Try one refresh + retry before giving up
            if authenticated && !isRetry {
                do {
                    try await SupabaseManager.shared.refreshSession()
                } catch {
                    throw APIError.unauthorized
                }
                return try await request(
                    path: path,
                    method: method,
                    body: body,
                    authenticated: authenticated,
                    isRetry: true
                )
            }
            throw APIError.unauthorized
        case 403:
            throw APIError.forbidden
        case 404:
            throw APIError.notFound
        case 429:
            throw APIError.rateLimited
        case 500..<600:
            throw APIError.serverError(status: http.statusCode)
        default:
            throw APIError.unknown
        }

        // Decode
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            #if DEBUG
            let raw = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            print("[APIClient] Decode error for \(path): \(error)\nRaw: \(raw.prefix(500))")
            #endif
            throw APIError.decoding(error.localizedDescription)
        }
    }
}
