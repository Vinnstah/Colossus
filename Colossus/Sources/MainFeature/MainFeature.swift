import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
public struct MainFeature {
    @Dependency(\.apiClient) var apiClient
    
    @ObservableState
    public struct State: Equatable {
        @Presents var alert: AlertState<MainFeature.Action.Alert>?
        var path = StackState<Path.State>()
        var orderBooks: [OrderBook] = []
        var symbols: [AssetPair] = AssetPair.listOfAssetPairs
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
    
    public var body: some Reducer<State, Action> {
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
                state.path.append(.addItem)
                return .none
                
            case .alert, .path:
                return .none
                    
            }
        }
        .forEach(\.path, action: \.path) {
          Path()
        }
    }
}

@Reducer
public struct Path {
    @ObservableState
    public enum State {
        case addItem
    }
    
    public enum Action {
        case addItem
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.addItem, action: \.addItem) {
            EmptyReducer()
        }
    }
}
