import CryptoServiceUniFFI
import Foundation
import Dependencies

public struct RustAPIClient: DependencyKey, Sendable {
    public typealias GetListOfCoins = @Sendable () async throws -> [Coin]
    public typealias GetCoinMetaInfo = @Sendable (String) async throws -> CoinMeta
    
    var getListOfCoins: GetListOfCoins
    var getCoinMetaInfo: GetCoinMetaInfo
    
    public init(
        getListOfCoins: @escaping GetListOfCoins,
        getCoinMetaInfo: @escaping GetCoinMetaInfo
    ) {
        self.getListOfCoins = getListOfCoins
        self.getCoinMetaInfo = getCoinMetaInfo
    }
    
    public static var liveValue: Self {
        @Dependency(\.urlSession) var urlSession
        
        let client = Gateway(networkAntenna: urlSession)
        
        return Self(
            getListOfCoins: {
                return try await client.getListOfCoins(limit: 10)
            }, getCoinMetaInfo: { symbol in
                return try await client.getCoinMetaInfo(code: symbol)
            } )
    }
}

extension RustAPIClient {
    
    public static let testValue = Self(
        getListOfCoins: unimplemented(
            "\(Self.self).getAggregatedListOfCoins"
        ), getCoinMetaInfo: unimplemented(
            "\(Self.self).getCoinMetaInfo"
        ))
}

extension DependencyValues {
    public var rustGateway: RustAPIClient {
        get { self[RustAPIClient.self] }
        set { self[RustAPIClient.self] = newValue }
    }
}
