import Foundation
import SwiftUI
import ComposableArchitecture
import CryptoService

extension MainFeature {
    @ViewAction(for: MainFeature.self)
    public struct View: SwiftUI.View {
        @Bindable public var store: StoreOf<MainFeature>
        public var body: some SwiftUI.View {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                
                ZStack {
                    Color("Background").ignoresSafeArea()
                    VStack {
                        Section {
                            Header()
                            ScrollView {
                                ForEach(store.orderBooks, id: \.self) { orderBook in
                                    SymbolItem(orderBook: orderBook)
                                        .onTapGesture {
                                            send(.inspectCoin(orderBook))
                                        }
                                }
                            }
                        } header: {
                            Text("Crypto")
                                .foregroundStyle(Color.white)
                        }
                    }
                    .toolbar {
                        ToolbarItem {
                            Button(action: {}, label: {
                                Image(systemName: "wallet.pass")
                                    .foregroundStyle(Color.indigo.opacity(50))
                            })
                        }
                    }
                }
            } destination: { store in
                switch store.state {
                case .coin:
                    if let store = store.scope(state: \.coin, action: \.coin) {
                        CoinFeature.View(store: store)
                    }
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
            ZStack {
                Capsule(style: .continuous)
                    .tint(.indigo)
                    .shadow(color: .indigo.opacity(50), radius: 2)
//                    .padding(5)
                //            Text(orderBook.bids.first?.first ?? "N/A")
                //                                .font(.caption)
                //                                .foregroundStyle(.white)
                //            Text(orderBook.asks.first?.first ?? "N/A")
                //                                .font(.caption)
                //                                .foregroundStyle(.white)
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
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 50)
        .padding(5)
    }
}


struct Header: View {
    var body: some View {
        HStack(spacing: 30) {
            Text("Name")
                .foregroundStyle(Color("AccentColor"))
            Spacer()
            Text("Bid")
                .foregroundStyle(Color("AccentColor"))
            Text("Ask")
                .foregroundStyle(Color("AccentColor"))
        }
        .padding(.leading)
        .padding(.trailing, 50)
    }
}
