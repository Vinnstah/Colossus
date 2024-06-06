import CryptoServiceUniFFI
import Foundation
import DependenciesAdditions


extension FfiNetworkingRequest {
    func urlRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = self.method
        request.httpBody = self.body
        request.allHTTPHeaderFields = self.headers
        return request
    }
}

extension URLSession: NetworkAntenna {
    public func getApiKeys() -> CryptoServiceUniFFI.ClientKeys {
        URLSession.clientKeys
    }
    
    private static let clientKeys = ClientKeys(
        binance: ProcessInfo.processInfo.environment["COIN_WATCH"] ?? "",
        coinWatch: ProcessInfo.processInfo.environment["COIN_WATCH"] ?? "",
        alpha: ProcessInfo.processInfo.environment["COIN_WATCH"] ?? ""
    )
    public func getBinanceKey() -> CryptoServiceUniFFI.ClientKeys {
        URLSession.clientKeys
    }
    
    public func getCoinwatchKey() -> CryptoServiceUniFFI.ClientKeys {
        URLSession.clientKeys
    }
    
    public func getAlphaKey() -> CryptoServiceUniFFI.ClientKeys {
        URLSession.clientKeys
    }
    
    public func makeRequest(request: CryptoServiceUniFFI.FfiNetworkingRequest) async throws -> CryptoServiceUniFFI.FfiNetworkingResponse {
        guard let url = URL(string: request.url) else {
            return FfiNetworkingResponse.init(statusCode: 500, body: .init())
        }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = request.body
        urlRequest.allHTTPHeaderFields = request.headers
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print(data)
            print(response)
            return FfiNetworkingResponse(statusCode: 400, body: data)
        }
        
        return FfiNetworkingResponse(statusCode: 200, body: data)
    }
}
class APIClient: Gateway {
    let client: Gateway = .init(networkAntenna:  URLSession.shared )
}
