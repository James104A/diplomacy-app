import Foundation

// MARK: - API Error

struct APIError: Decodable, Error {
    let error: APIErrorDetail
}

struct APIErrorDetail: Decodable {
    let code: String
    let message: String
    let details: [String: String]?
    let recovery: String?
}

enum NetworkError: Error, LocalizedError {
    case noAccessToken
    case unauthorized
    case forbidden
    case notFound
    case conflict
    case unprocessable(APIErrorDetail?)
    case rateLimited(retryAfter: Int?)
    case serverError
    case decodingError(Error)
    case networkError(Error)
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .noAccessToken: return "Please sign in to continue."
        case .unauthorized: return "Your session has expired. Please sign in again."
        case .forbidden: return "You don't have permission to do that."
        case .notFound: return "The requested content could not be found."
        case .conflict: return "This action conflicts with a recent change. Please refresh and try again."
        case .unprocessable(let detail): return detail?.message ?? "The request couldn't be processed. Please check your input."
        case .rateLimited: return "You're doing that too fast. Please wait a moment and try again."
        case .serverError: return "Something went wrong on our end. Please try again in a moment."
        case .decodingError: return "We received an unexpected response. Please try again."
        case .networkError(let err):
            if (err as NSError).code == NSURLErrorNotConnectedToInternet {
                return "No internet connection. Please check your network and try again."
            }
            if (err as NSError).code == NSURLErrorTimedOut {
                return "The request timed out. Please check your connection and try again."
            }
            return "A network error occurred. Please check your connection and try again."
        case .invalidURL: return "Invalid URL"
        }
    }

    var isRetryable: Bool {
        switch self {
        case .serverError, .rateLimited, .networkError: return true
        default: return false
        }
    }
}

// MARK: - API Client

actor APIClient {
    static let shared = APIClient()

    private let baseURL: String
    private let session: URLSession
    private var isRefreshing = false
    private var pendingRequests: [CheckedContinuation<Data, Error>] = []

    init(baseURL: String = "http://localhost:8080/v1") {
        self.baseURL = baseURL
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }

    // MARK: - Public API

    func get<T: Decodable>(_ path: String, queryItems: [URLQueryItem]? = nil) async throws -> T {
        let data = try await request(method: "GET", path: path, queryItems: queryItems)
        return try decode(data)
    }

    func post<T: Decodable>(_ path: String, body: Encodable? = nil) async throws -> T {
        let data = try await request(method: "POST", path: path, body: body)
        return try decode(data)
    }

    func put<T: Decodable>(_ path: String, body: Encodable? = nil) async throws -> T {
        let data = try await request(method: "PUT", path: path, body: body)
        return try decode(data)
    }

    func delete(_ path: String) async throws {
        _ = try await request(method: "DELETE", path: path)
    }

    func postVoid(_ path: String, body: Encodable? = nil) async throws {
        _ = try await request(method: "POST", path: path, body: body)
    }

    func putVoid(_ path: String, body: Encodable? = nil) async throws {
        _ = try await request(method: "PUT", path: path, body: body)
    }

    // MARK: - Request Pipeline

    private func request(
        method: String,
        path: String,
        queryItems: [URLQueryItem]? = nil,
        body: Encodable? = nil,
        isRetry: Bool = false
    ) async throws -> Data {
        guard var components = URLComponents(string: baseURL + path) else {
            throw NetworkError.invalidURL
        }
        components.queryItems = queryItems

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Attach JWT
        if let token = KeychainManager.load(key: .accessToken) {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Encode body
        if let body = body {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            urlRequest.httpBody = try encoder.encode(AnyEncodable(body))
        }

        do {
            let (data, response) = try await session.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.serverError
            }

            switch httpResponse.statusCode {
            case 200...299:
                return data

            case 401:
                if !isRetry {
                    // Try token refresh, then retry
                    try await refreshTokenIfNeeded()
                    return try await request(method: method, path: path, queryItems: queryItems, body: body, isRetry: true)
                }
                throw NetworkError.unauthorized

            case 403:
                throw NetworkError.forbidden

            case 404:
                throw NetworkError.notFound

            case 409:
                throw NetworkError.conflict

            case 422:
                let apiError = try? JSONDecoder().decode(APIError.self, from: data)
                throw NetworkError.unprocessable(apiError?.error)

            case 429:
                let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After").flatMap(Int.init)
                throw NetworkError.rateLimited(retryAfter: retryAfter)

            default:
                throw NetworkError.serverError
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error)
        }
    }

    // MARK: - Token Refresh

    private func refreshTokenIfNeeded() async throws {
        guard let refreshToken = KeychainManager.load(key: .refreshToken) else {
            throw NetworkError.unauthorized
        }

        guard var components = URLComponents(string: baseURL + "/auth/refresh") else {
            throw NetworkError.invalidURL
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["refreshToken": refreshToken]
        urlRequest.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            // Refresh failed — clear tokens
            KeychainManager.clearAll()
            throw NetworkError.unauthorized
        }

        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        KeychainManager.save(tokenResponse.accessToken, for: .accessToken)
        KeychainManager.save(tokenResponse.refreshToken, for: .refreshToken)
    }

    // MARK: - Helpers

    private func decode<T: Decodable>(_ data: Data) throws -> T {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}

// MARK: - Token Response

struct TokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}

// MARK: - Type-erased Encodable wrapper

private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init(_ value: Encodable) {
        _encode = { encoder in
            try value.encode(to: encoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
