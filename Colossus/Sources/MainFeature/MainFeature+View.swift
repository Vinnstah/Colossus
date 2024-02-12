import Foundation
import SwiftUI
import ComposableArchitecture

extension MainFeature {
    @ViewAction(for: MainFeature.self)
    public struct View: SwiftUI.View {
        @Bindable public var store: StoreOf<MainFeature>
        public var body: some SwiftUI.View {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                
                ZStack {
                    Color.background.ignoresSafeArea()
                    VStack {
                        Header()
                        ScrollView {
                            ForEach(store.orderBooks, id: \.self) { orderBook in
                                SymbolItem(orderBook: orderBook)
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add Coin") {
                            send(.addCoin)
                        }
                    }
                }
            } destination: { store in
                switch store.state {
                case .addItem:
                    EmptyView()
                }
            }
            .onAppear {
                send(.onAppear)
            }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

struct SymbolItem: View {
    let orderBook: OrderBook
    
    var body: some View {
        VStack {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Image(orderBook.pair.symbol.from)
                    .resizable()
                    .frame(width: 25, height: 25)
                Text(orderBook.pair.symbol.from.description)
                    .font(.title2)
                    .foregroundStyle(.white)
                Spacer()
                Text(orderBook.fetchedOrderBook.highestBid?.formattedPrice ?? "N/A")
                    .font(.caption)
                    .foregroundStyle(.white)
            Text(orderBook.fetchedOrderBook.lowestAsk?.formattedPrice ?? "N/A")
                    .font(.caption)
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 75)
        .padding(15)
    }
}

struct Header: View {
    var body: some View {
        HStack(spacing: 30) {
            Text("Name")
                .foregroundStyle(.accent)
            Spacer()
            Text("Bid")
                .foregroundStyle(.accent)
            Text("Ask")
                .foregroundStyle(.accent)
        }
        .padding(.leading)
        .padding(.trailing, 50)
    }
}
