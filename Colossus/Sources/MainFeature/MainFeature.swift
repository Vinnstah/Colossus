import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
public struct MainFeature {
    @Dependency(\.apiClient) var apiClient
    
    @ObservableState
    public struct State: Equatable {
        @Presents var alert: AlertState<MainFeature.Action.Alert>?
        public var path = StackState<Path.State>()
        public var orderBooks: [OrderBook] = []
        public var symbols: [AssetPair] = AssetPair.listOfAssetPairs
    }
    
    public enum Action: ViewAction {
        case alert(PresentationAction<Alert>)
        case orderbookResult(Result<AnonymousOrderBook, Swift.Error>, AssetPair)
        case view(View)
        case path(StackAction<Path.State, Path.Action>)
        
        public enum Alert: Equatable {
            case dissmissed
            case retry
        }
        
        public enum View {
            case onAppear
            case addCoin
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .view(.onAppear):
                return .run { [symbols = state.symbols] send in
                    for assetPair in symbols {
                        let result = await Result {
                            try await apiClient.getOrderbook(
                                assetPair
                            )
                        }
                        await send(.orderbookResult(result, assetPair))
                    }
                }
                
            case let .orderbookResult(.success(orderbook), assetPair):
                let orderbook = OrderBook(pair: assetPair, fetchedOrderBook: orderbook)
                state.orderBooks.append(orderbook)
                print(orderbook)
                return .none
                
            case let .orderbookResult(.failure(error), assetPair):
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
                return .none
                
            case .alert(.presented(.retry)):
                state.alert = nil
                return .run { send in
                    await send(.view(.onAppear)) }
                
            case .view(.addCoin):
                state.path.append(.addItem(.init()))
                return .none
                
            case .alert, .path:
                return .none
                    
            }
        }
        .forEach(\.path, action: \.path)
    }
}

@Reducer(state: .equatable)
public enum Path {
    case addItem(AddItem)
}

@Reducer
public struct AddItem {}
