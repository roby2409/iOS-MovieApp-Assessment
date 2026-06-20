import Foundation

// MARK: - Result type for completion-handler style consumption
// Mirrors: .success(model, message) / .error(NetworkError)

public enum APIResult<Value> {
    case success(Value, String?)
    case error(NetworkError)
}

// MARK: - Protocol (biar gampang di-mock di Unit Test)

public protocol APIManagerProtocol {
    @discardableResult
    func hitAPIWithResultAndError<T: Decodable>(
        endpoint: Endpoint,
        path: String,
        query: String?,
        httpMethod: HTTPMethod,
        queryItems: [URLQueryItem],
        body: Encodable?,
        headers: [String: String],
        timeoutInterval: TimeInterval,
        model: T.Type,
        completion: @escaping (APIResult<T>) -> Void
    ) -> URLSessionDataTask?

    // async/await variant — kept for places that prefer it (e.g. Task { } inside ViewModel)
    func send<T: Decodable>(_ request: APIRequest, decodeTo type: T.Type) async throws -> T
}

public extension APIManagerProtocol {
    @discardableResult
    func hitAPIWithResultAndError<T: Decodable>(
        endpoint: Endpoint,
        path: String = "",
        query: String? = nil,
        httpMethod: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        body: Encodable? = nil,
        headers: [String: String] = [:],
        timeoutInterval: TimeInterval = 30,
        model: T.Type,
        completion: @escaping (APIResult<T>) -> Void
    ) -> URLSessionDataTask? {
        hitAPIWithResultAndError(endpoint: endpoint, path: path, query: query, httpMethod: httpMethod, queryItems: queryItems, body: body, headers: headers, timeoutInterval: timeoutInterval, model: model, completion: completion)
    }
}

// MARK: - Implementation

public final class APIManager: APIManagerProtocol {

    public static let shared = APIManager()

    private let session: URLSession
    private let baseURL: String
    private let apiKey: String
    private let decoder: JSONDecoder
    private let reachability: NetworkReachability

    public init(
        session: URLSession = .init(configuration: .default),
        baseURL: String? = nil,
        apiKey: String? = nil,
        decoder: JSONDecoder = APIManager.makeDefaultDecoder(),
        reachability: NetworkReachability = NetworkMonitor.shared
    ) {
        self.session = session
        self.baseURL = baseURL ?? Environment.shared.configuration(.baseUrl)
        self.apiKey = apiKey ?? Environment.shared.configuration(.apiKey)
        self.decoder = decoder
        self.reachability = reachability
    }

    // MARK: - Completion-handler style (sesuai pattern yang lu pakai)

    @discardableResult
    public func hitAPIWithResultAndError<T: Decodable>(
        endpoint: Endpoint,
        path: String = "",
        query: String? = nil,
        httpMethod: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        body: Encodable? = nil,
        headers: [String: String] = [:],
        timeoutInterval: TimeInterval = 30,
        model: T.Type,
        completion: @escaping (APIResult<T>) -> Void
    ) -> URLSessionDataTask? {

        guard reachability.isConnected else {
            mainThread { completion(.error(.noInternetConnection)) }
            return nil
        }

        let apiRequest = APIRequest(endpoint: endpoint, path: path, query: query, method: httpMethod, queryItems: queryItems, body: body, headers: headers, timeoutInterval: timeoutInterval)

        let urlRequest: URLRequest
        do {
            urlRequest = try buildURLRequest(from: apiRequest)
        } catch {
            mainThread { completion(.error(NetworkError.from(error))) }
            return nil
        }

        let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                mainThread { completion(.error(NetworkError.from(error))) }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                mainThread { completion(.error(.invalidResponse)) }
                return
            }

            if let statusError = NetworkError.from(statusCode: httpResponse.statusCode) {
                mainThread { completion(.error(statusError)) }
                return
            }

            guard let data = data else {
                mainThread { completion(.error(.invalidResponse)) }
                return
            }

            do {
                let decoded = try self.decoder.decode(T.self, from: data)
                mainThread { completion(.success(decoded, nil)) }
            } catch {
                mainThread { completion(.error(NetworkError.from(error))) }
            }
        }
        task.resume()
        return task
    }

    // MARK: - async/await style (opsional dipakai di ViewModel kalau mau)

    public func send<T: Decodable>(_ request: APIRequest, decodeTo type: T.Type) async throws -> T {
        guard reachability.isConnected else {
            throw NetworkError.noInternetConnection
        }

        let urlRequest = try buildURLRequest(from: request)

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw NetworkError.from(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if let statusError = NetworkError.from(statusCode: httpResponse.statusCode) {
            throw statusError
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.from(error)
        }
    }

    // MARK: - Request builder

    private func buildURLRequest(from request: APIRequest) throws -> URLRequest {
        guard var components = URLComponents(string: "\(baseURL)/\(request.fullPath)") else {
            throw NetworkError.invalidURL
        }

        var items = request.parsedQueryItems
        items.append(URLQueryItem(name: "api_key", value: apiKey))
        components.queryItems = items

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = request.timeoutInterval
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }

        if let body = request.body {
            do {
                urlRequest.httpBody = try JSONEncoder().encode(AnyEncodable(body))
            } catch {
                throw NetworkError.unknown("Failed to encode request body")
            }
        }

        return urlRequest
    }

    public static func makeDefaultDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}

// MARK: - Type-erased wrapper to encode `Encodable` existential

private struct AnyEncodable: Encodable {
    private let encodeClosure: (Encoder) throws -> Void

    init(_ wrapped: Encodable) {
        encodeClosure = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}
