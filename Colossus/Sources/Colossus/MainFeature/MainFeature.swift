import Foundation
import SwiftUI
import ComposableArchitecture
import IdentifiedCollections
import CryptoServiceUniFFI

@Reducer
public struct MainFeature : Sendable{
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.uuid) var uuid
    @Dependency(\.rustGateway) var rustGateway
    
    @Reducer(state: .equatable)
    public enum Path {
        case coin(CoinFeature)
    }
    
    @ObservableState
    public struct State: Equatable {
        @Presents var alert: AlertState<MainFeature.Action.Alert>?
        public var path = StackState<Path.State>()
        public var coins: IdentifiedArrayOf<CoinMeta> = []
        public var orderBooks: [OrderBook] = []
        public var symbols: [AssetPair] = AssetPair.listOfAssetPairs
        let user: User
        var selectedTopic: User.Topic = .crypto
        
        var isExpandingCryptoScrollView: Bool = false
    }
    
    public enum Action: ViewAction, Sendable {
        case alert(PresentationAction<Alert>)
        case orderbookResult(Result<[CoinMeta], Swift.Error>)
        case coinHistoryResult(Result<CoinHistory, Swift.Error>)
        case view(View)
        case path(StackAction<Path.State, Path.Action>)
        
        public enum Alert: Equatable, Sendable {
            case dissmissed
            case retry
        }
        
        public enum View : Sendable{
            case onAppear
            case seeAllTapped
            case inspectCoinTapped(CoinMeta)
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
                
            case .view(.onAppear):
                return .run { send in
                    
                    //                    await withThrowingTaskGroup(of: Void.self) { group in
                    //                        for assetPair in symbols {
                    //                            group.addTask {
//                    let result = await Result {
//                        try await self.rustGateway.getListOfCoins()
//                        //                                    try await self.rustGateway.getCoinMetaInfo(assetPair.symbol.from)
//                    }
                    await send(
                        .orderbookResult(
                            await Result {
                                try await self.rustGateway.getListOfCoins()
                            }
                        )
                    )
                }
                
            case .view(.seeAllTapped):
                state.isExpandingCryptoScrollView.toggle()
                return .none
                
            case let .orderbookResult(.success(coins)):
                print("12345")
                state.coins.append(contentsOf: coins)
                return .none
                
            case let .orderbookResult(.failure(error)):
#if DEBUG
                state.orderBooks = OrderBook.mock
                
#else
                state.alert = AlertState {
                    TextState("Alert!")
                } actions: {
                    ButtonState(action: .send(.retry)) {
                        TextState("Try Again")
                    }
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
#endif
                
                return .none
                
            case .alert(.presented(.retry)):
                state.alert = nil
                return .run { send in
                    await send(.view(.onAppear)) }
                
            case .alert,
                    .path:
                return .none
                
            case let .view(.inspectCoinTapped(coin)):
                print("Here1")
                print(UInt64(Date().timeIntervalSince1970) - 605_000)
                print("Here2")
                print(UInt64(Date().timeIntervalSince1970) )
                return .run { send in
                    await send(
                        .coinHistoryResult(
                            await Result {
                                try await self.rustGateway.getCoinHistory(
                                    .init(
                                        currency: "USD",
                                        code: coin.code ?? "",
//                                        start: UInt64(Date().millisecondsSince1970) - 605_000_000,
                                        start: UInt64(Date().millisecondsSince1970) - 262_974_300_0,
                                        end: UInt64(Date().millisecondsSince1970),
                                        meta: true
                                    )
                                )
                            }
                        )
                    )
                    
                }
            case let .coinHistoryResult(.success(coinMeta)):
                state.path.append(.coin(.init(coin: coinMeta)))
                return.none
                
            case .coinHistoryResult(.failure):
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension Date {
    var millisecondsSince1970:Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
