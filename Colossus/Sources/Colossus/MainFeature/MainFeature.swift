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
        public var orderBooks: [OrderBook] = []
        public var symbols: [AssetPair] = AssetPair.listOfAssetPairs
        let user: User
        var selectedTopic: User.Topic = .crypto
        
        var isExpandingCryptoScrollView: Bool = false
    }
    
    public enum Action: ViewAction, Sendable {
        case alert(PresentationAction<Alert>)
        case orderbookResult(Result<AnonymousOrderBook, Swift.Error>, AssetPair)
        //        case orderbookResult(Result<OrderBook, Swift.Error>, AssetPair)
        case view(View)
        case path(StackAction<Path.State, Path.Action>)
        
        public enum Alert: Equatable {
            case dissmissed
            case retry
        }
        
        public enum View {
            case onAppear
            case seeAllTapped
            case inspectCoinTapped(OrderBook)
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .view(.onAppear):
                return .run { [symbols = state.symbols] send in
//                    try await self.rustGateway.getListOfCoins()
//                    try await self.rustGateway.getMetaInfoCoin("BTsaC")
//                    print(try await apiClient.getAggregatedListOfCoins(.init(currency: "USD", sort: "rank", order: "ascending", offset: 0, limit: 15, meta: false)))
                    
//                    await withThrowingTaskGroup(of: Void.self) { group in
//                        for assetPair in symbols {
//                            group.addTask {
//                                let result = await Result {
//                                    try await apiClient.getOrderbook(
//                                        assetPair
//                                    )
//                                }
//                                await send(.orderbookResult(result, assetPair))
//                            }
//                        }
//                    }
                }
                
            case .view(.seeAllTapped):
                state.isExpandingCryptoScrollView.toggle()
                return .none
                
            case let .orderbookResult(.success(orderbook), assetPair):
                let orderbook = OrderBook(pair: assetPair, fetchedOrderBook: orderbook)
                state.orderBooks.append(orderbook)
                return .none
                
            case let .orderbookResult(.failure(error), assetPair):
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
                
            case .alert, .path:
                return .none
                
            case let .view(.inspectCoinTapped(orderBook)):
                state.path.append(.coin(.init(orderBook: orderBook)))
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
