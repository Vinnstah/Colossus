import ComposableArchitecture
import Foundation
import DependenciesAdditions
import CryptoService
import CryptoServiceUniFFI

public struct ApiClient: DependencyKey {
    public typealias GetSymbols = @Sendable () async throws -> ([Symbol])
    public typealias GetOrderbook = @Sendable (AssetPair) async throws -> (AnonymousOrderBook)
    public typealias GetListOfCoins = @Sendable (ListOfCoinsRequest) async throws -> ([Coin])
//    public typealias GetOrderbook = @Sendable (AssetPair) async throws -> (OrderBook)
    public var getSymbols: GetSymbols
    public var getOrderbook: GetOrderbook
    public var getListOfCoins: GetListOfCoins
    
    public init(
        getSymbols: @escaping GetSymbols,
        getOrderbook: @escaping GetOrderbook,
        getListOfCoins: @escaping GetListOfCoins
    ) {
        self.getSymbols = getSymbols
        self.getOrderbook = getOrderbook
        self.getListOfCoins = getListOfCoins
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
            urlRequest.timeoutInterval = 10
            
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
                return try await get(nil, path: "symbols", decodeAs: [Symbol].self)
            },
            getOrderbook: { assetPair in
//                let binanceKey = ProcessInfo.processInfo.environment["BINANCE_API_KEY"]
//                let coinKey = ProcessInfo.processInfo.environment["BINANCE_API_KEY"]
//                let client = Client(binanceKey: binanceKey ?? "", coinApiKey: coinKey ?? "")
//                return await client.getOrderbook(params: .init(symbol: assetPair.symbol.description, limit: UInt16(assetPair.limit ?? 1)))
                try await get(assetPair, path: "orderbooks", decodeAs: AnonymousOrderBook.self)
            }, getListOfCoins: { request in
                try await get(request, path: "", decodeAs: [Coin].self)
                
                
            }
        )
    }
}

extension ListOfCoinsRequest: QueryItemsExpressible {
    public var queryItems: [URLQueryItem] {
        []
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
        getSymbols: unimplemented(
            "\(Self.self).getSymbols"
        ),
        getOrderbook: unimplemented(
            "\(Self.self).getOrderBook"
        ),
        getListOfCoins: unimplemented(
            "\(Self.self).getListOfCoins"
        )
    )
}

extension DependencyValues {
    public var apiClient: ApiClient {
        get { self[ApiClient.self] }
        set { self[ApiClient.self] = newValue }
    }
}


public protocol NetworkManager {
    func send() -> Bool
    func create() -> Result<Bool, Error>
}

public struct RustApiClient: NetworkManager {
    public func send() -> Bool {
        URLSession().dataTask(with: URLRequest.init(url: URL.init(string: "tst")!)) { completion,data,err  in
            
            return
        }
        return true
    }
    
    public func create() -> Result<Bool, Error> {
        return .success(true)
    }
    
    
}
