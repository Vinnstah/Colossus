import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
public struct MainFeature {
    @Dependency(\.apiClient) var apiClient
    
    @ObservableState
    public struct State: Equatable {
        @Presents var alert: AlertState<MainFeature.Action.Alert>?
        fileprivate var orderBooks: [OrderBook] = []
        fileprivate var symbols: [AssetPair] = AssetPair.listOfAssetPairs
    }
    
    public enum Action: ViewAction {
        case alert(PresentationAction<Alert>)
        case orderbookResult(Result<AnonymousOrderBook, Swift.Error>, AssetPair)
        case view(View)
        
        public enum Alert: Equatable {
            case dissmissed
            case retry
        }
        
        public enum View {
            case onAppear
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
                NavigationStack {
                    ZStack {
                        Color.background.ignoresSafeArea()
                        VStack {
                            ScrollView {
                                ForEach(store.orderBooks, id: \.self) { orderBook in
                                    SymbolListItem(orderBook: orderBook)
                                }
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Text("Add Coin")
                        }
                    }
                    .onAppear {
                        send(.onAppear)
                    }
                    .alert($store.scope(state: \.alert, action: \.alert))
                }
            }
        }
    }

struct SymbolListItem: View {
    let orderBook: OrderBook
    
    var body: some View {
        VStack {
            HStack(alignment: .firstTextBaseline) {
                Image(orderBook.pair.symbol.from)
                    .resizable()
                    .frame(width: 25, height: 25)
                Text(orderBook.pair.symbol.from.description)
                    .font(.title2)
                Spacer()
            }
            Text("Highest bid \(orderBook.fetchedOrderBook.highestBid?.description ?? "--")")
            Text("Lowest ask \(orderBook.fetchedOrderBook.lowestAsk?.description ?? "--")")
        }
        .frame(maxWidth: .infinity, maxHeight: 100)
        .padding(15)
        .background(Color.accentColor)
        .presentationCornerRadius(25)
    }
}
