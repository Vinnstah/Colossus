import Foundation
import SwiftUI
import ComposableArchitecture

extension CoinFeature {
    public struct View: SwiftUI.View  {
        let store: StoreOf<CoinFeature>
        
        public var body: some SwiftUI.View  {
            Text(store.orderBook?.pair.symbol.from ?? "")
                .font(.headline)
            Form {
                Section("Price") {
                    Text("Highest bid: \(store.orderBook?.fetchedOrderBook.highestBid?.description ?? "")")
                    Text("Lowest ask: \(store.orderBook?.fetchedOrderBook.lowestAsk?.description ?? "")")
                    Text("Coin")
                }
                
            }
        }
    }
}
