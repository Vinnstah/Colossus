import ComposableArchitecture
import Foundation
import DependenciesAdditions

public struct ApiClient: DependencyKey {
    public typealias GetSymbols = @Sendable () async throws -> ([Symbol])
    public typealias GetOrderbook = @Sendable (AssetPair) async throws -> (AnonymousOrderBook)
    public var getSymbols: GetSymbols
    public var getOrderbook: GetOrderbook
    
    public init(getSymbols: @escaping GetSymbols, getOrderbook: @escaping GetOrderbook) {
        self.getSymbols = getSymbols
        self.getOrderbook = getOrderbook
    }
    
}

extension ApiClient {
    
    public static var liveValue: Self {
        
        @Dependency(\.urlSession) var urlSession
        @Dependency(\.decode) var decode
        @Dependency(\.encode) var encode
        
        @Sendable func makeRequest<T>(
            path: String,
            method: Method,
            decodeAs: T.Type = T.self
        ) async throws -> T where T: Decodable {
            let baseURL = URL(string: "http://localhost:3000/v1/")!
            
            let url: URL = {
                guard var urlComponents = URLComponents(
                    url: baseURL.appending(path: path),
                    resolvingAgainstBaseURL: true
                ) else {
                    fatalError("no components")
                }
                if case let .get(queryParams) = method {
                    urlComponents.queryItems = queryParams
                }
                
                guard let url = urlComponents.url else {
                    fatalError("Failed to construct URL")
                }
                return url
            }()
            
            var urlRequest = URLRequest(url: url)
            
            urlRequest.httpMethod = method.discriminator.rawValue
            
            if case let .post(data) = method {
                urlRequest.httpBody = data
            }
            
            
            urlRequest.allHTTPHeaderFields = [
                "Content-Type": "application/json"
            ]
            print(urlRequest)
            let (data, urlResponse) = try await urlSession.data(for: urlRequest)
            
            guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
                fatalError("HANDLE ERROR")
            }
            
            guard 200...299 ~= httpURLResponse.statusCode else {
                print(httpURLResponse.statusCode)
                print(String(data: data, encoding: .utf8)!)
                print(url.pathComponents)
                fatalError("Handle API Errors")
            }
            return try decode(T.self, from: data)
        }
        
        @Sendable func get<Response>(
            _ queryItemsExpressible: (any QueryItemsExpressible)?,
            path: String,
            decodeAs: Response.Type = Response.self
        ) async throws -> Response where Response: Decodable {
            try await makeRequest(path: path, method: .get(queryItems: queryItemsExpressible?.queryItems ?? []))
        }
        
        return Self(
            getSymbols: {
                print("123")
                return try await get(nil, path: "symbols", decodeAs: [Symbol].self)
            },
            getOrderbook: { assetPair in
                try await get(assetPair, path: "orderbooks", decodeAs: AnonymousOrderBook.self)
            }
        )
    }
}

public enum Method {
    case get(queryItems: [URLQueryItem] = [])
    case post(data: Data = .init())
    
    public static func post<T>(
        _ model: T
    ) throws -> Self where T: Encodable {
        @Dependency(\.encode) var encode
        
        return try .post(data: encode(model))
    }
    
    public static func get(
        _ itemsExpressible: some QueryItemsExpressible
    ) throws -> Self  {
        return get(queryItems: itemsExpressible.queryItems)
    }
    
    
    public enum Discriminator: String {
        case get = "GET"
        case post = "POST"
    }
    
    public var discriminator: Discriminator {
        switch self {
        case .get:
            return .get
        case .post:
            return .post
        }
    }
}

extension ApiClient {
    
    public static let testValue = Self(
        getSymbols: unimplemented("\(Self.self).getSymbols"), 
        getOrderbook: unimplemented("\(Self.self).getOrderBook")
    )
}

extension DependencyValues {
    public var apiClient: ApiClient {
        get { self[ApiClient.self] }
        set { self[ApiClient.self] = newValue }
    }
}
