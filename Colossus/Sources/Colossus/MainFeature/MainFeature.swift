import Foundation
import SwiftUI
import ComposableArchitecture
import IdentifiedCollections
import CryptoServiceUniFFI

@Reducer
public struct MainFeature {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.uuid) var uuid
    
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
    }
    
    public enum Action: ViewAction {
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
            case inspectCoin(OrderBook)
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .view(.onAppear):
                return .run { [symbols = state.symbols] send in
                     await withThrowingTaskGroup(of: Void.self) { group in
                        for assetPair in symbols {
                            group.addTask {
                                let result = await Result {
                                    try await apiClient.getOrderbook(
                                        assetPair
                                    )
                                }
                                await send(.orderbookResult(result, assetPair))
                            }
                        }
                    }
                }
                
            case let .orderbookResult(.success(orderbook), assetPair):
                let orderbook = OrderBook(pair: assetPair, fetchedOrderBook: orderbook)
                state.orderBooks.append(orderbook)
                print(orderbook)
                return .none
                
            case let .orderbookResult(.failure(error), assetPair):
                state.orderBooks = OrderBook.mock
//                state.alert = AlertState {
//                    TextState("Alert!")
//                } actions: {
//                    ButtonState(action: .send(.retry)) {
//                        TextState("Try Again")
//                    }
//                    ButtonState(role: .cancel) {
//                        TextState("Cancel")
//                    }
//                } message: {
//                    TextState(error.localizedDescription)
//                }
                return .none
                
            case .alert(.presented(.retry)):
                state.alert = nil
                return .run { send in
                    await send(.view(.onAppear)) }
                
            case .alert, .path:
                return .none
                    
            case let .view(.inspectCoin(orderBook)):
                state.path.append(.coin(.init(orderBook: orderBook)))
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}


