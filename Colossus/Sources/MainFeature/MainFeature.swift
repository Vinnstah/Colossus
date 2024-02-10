import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
public struct MainFeature {
    @Dependency(\.apiClient) var apiClient
}

extension MainFeature {
    @ObservableState
    public struct State: Equatable {
        @Presents var alert: AlertState<MainFeature.Action.Alert>?
        var orderBooks: [OrderBook] = []
        var symbols: [AssetPair] = AssetPair.listOfAssetPairs
        var isLoading: Bool = false
    }
    
    public enum Action: ViewAction {
        case alert(PresentationAction<Alert>)
        case orderbookResult(Result<AnonymousOrderBook, Swift.Error>, AssetPair)
        case view(View)
        
        public enum Alert: Equatable {
            case dissmissed
        }
        
        public enum View {
            case onAppear
        }
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                state.isLoading = true
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
                state.isLoading = false
                print(orderbook)
                return .none
                
            case let .orderbookResult(.failure(error), assetPair):
                /// TODO: Alert is not working
                state.alert = AlertState {
                    TextState("Alert!")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none
                
                
            case .alert:
                return .none
            }
        }
    }
}

extension MainFeature {
    @ViewAction(for: MainFeature.self)
    public struct View: SwiftUI.View {
        @Bindable public var store: StoreOf<MainFeature>
        public var body: some SwiftUI.View {
            VStack {
                if !store.isLoading {
                    List {
                        ForEach(store.orderBooks, id: \.self) { orderBook in
                            VStack {
                                HStack {
                                    Text(orderBook.pair.symbol.from.description)
                                    Image(orderBook.pair.symbol.from)
                                }
                                Text("Highest bid \(orderBook.fetchedOrderBook.highestBid?.description ?? "--")")
                                Text("Lowest ask \(orderBook.fetchedOrderBook.lowestAsk?.description ?? "--")")
                            }
                        }
                    }
                } else {
                    Text("Loading")
                }
            }
            .onAppear {
                send(.onAppear)
            }
        }
    }
}


