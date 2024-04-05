import Foundation
import SwiftUI
import ComposableArchitecture
import CryptoService

extension MainFeature {
    @ViewAction(for: MainFeature.self)
    public struct View: SwiftUI.View {
        @Bindable public var store: StoreOf<MainFeature>
        public var body: some SwiftUI.View {
            GeometryReader { geo in
                NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                    ZStack {
                        Color("Background").ignoresSafeArea()
                        VStack {
                            cryptoScrollView()
                                .frame(
                                    height: store.isExpandingCryptoScrollView ? (geo.size.height / 1.5) : geo.size.height / 3
                                )
                                .animation(.easeIn(duration: 0.5), value: store.isExpandingCryptoScrollView)
                                .padding(.bottom, 25)
                                .padding(.horizontal, 10)
                            
                            MyAssets(assets: store.orderBooks)
                            Spacer()
                        }
                        .toolbar {
                            ToolbarItem {
                                Button(action: {
                                    // Navigate to Wallet
                                    fatalError()
                                }, label: {
                                    Image(systemName: "wallet.fill")
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
}

extension MainFeature.View {
    @ViewBuilder
    func cryptoScrollView() -> some View {
        VStack {
            Section {
                Header()
                ScrollView {
                    ForEach(store.coins) { coin in
                        SymbolItem(coin: coin)
                    }
//                    ForEach(store.coins) { coin in
//                        SymbolItem(coin: coin)
//                    }
//                    ForEach(store.orderBooks, id: \.self) { orderBook in
//                        SymbolItem(orderBook: orderBook)
//                            .onTapGesture {
//                                send(.inspectCoinTapped(orderBook))
//                            }
//                    }
//                                                .onTapGesture {
//                                                    send(.inspectCoinTapped(coin))
//                                                }
                }
            } header: {
                HStack {
                    //                                Picker("Choose a topic", selection: $store.selectedTopic.rawValue) {
                    //                                    ForEach(store.user.topics, id: \.self) {
                    //                                        Text($0.rawValue)
                    //                                            .foregroundStyle(Color.white)
                    //                                                }
                    //                                            }
                    //                                .pickerStyle(.menu)
                    
                    Text("Crypto")
                        .foregroundStyle(Color.white)
                        .padding(.leading, 10)
                    Spacer()
                    Button(store.isExpandingCryptoScrollView ? "Collapse" : "See all") {
                        send(.seeAllTapped)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .font(.caption)
                }
            }
        }
    }
}







