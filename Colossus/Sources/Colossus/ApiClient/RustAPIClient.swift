import CryptoServiceUniFFI
import Foundation
import Dependencies

public struct RustAPIClient: DependencyKey, Sendable {
    public typealias GetListOfCoins = @Sendable () async throws -> [CoinMeta]
    public typealias GetCoinMetaInfo = @Sendable (CoinMetaRequest) async throws -> CoinMeta
    public typealias GetCoinHistory = @Sendable (CoinHistoryRequest) async throws -> CoinHistory
    
    var getListOfCoins: GetListOfCoins
    var getCoinMetaInfo: GetCoinMetaInfo
    var getCoinHistory: GetCoinHistory
    
    public init(
        getListOfCoins: @escaping GetListOfCoins,
        getCoinMetaInfo: @escaping GetCoinMetaInfo,
        getCoinHistory: @escaping GetCoinHistory
    ) {
        self.getListOfCoins = getListOfCoins
        self.getCoinMetaInfo = getCoinMetaInfo
        self.getCoinHistory = getCoinHistory
    }
    
    public static var liveValue: Self {
        @Dependency(\.urlSession) var urlSession
        
        let client = Gateway(networkAntenna: urlSession)
        
        return Self(
            getListOfCoins: {
                return try await client.getListOfCoins(limit: 15)
            }, getCoinMetaInfo: { request in
                return try await client.getCoinMetaInfo(request: request)
            }, getCoinHistory: { request in
                return try await client.getCoinHistoryInfo(request: request)
            } )
    }
}

extension RustAPIClient {
    
    public static let testValue = Self(
        getListOfCoins: unimplemented(
            "\(Self.self).getAggregatedListOfCoins"
        ), getCoinMetaInfo: unimplemented(
            "\(Self.self).getCoinMetaInfo"
        ), getCoinHistory: unimplemented(
            "\(Self.self).getCoinHistory"
        ))
}

extension DependencyValues {
    public var rustGateway: RustAPIClient {
        get { self[RustAPIClient.self] }
        set { self[RustAPIClient.self] = newValue }
    }
}
