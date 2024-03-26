import Foundation
import SwiftUI

struct SymbolItem: View {
    let orderBook: OrderBook
    
    var body: some View {
        HStack {
            Image(orderBook.pair.symbol.from)
                .resizable()
                .frame(width: 25, height: 25)
            VStack(alignment: .leading) {
                Text(orderBook.pair.symbol.from)
                    .foregroundStyle(Color.white)
                Text(orderBook.pair.symbol.from)
                    .foregroundStyle(Color("AccentColor"))
                    .font(.caption)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(orderBook.fetchedOrderBook.lowestAsk?.formattedPrice ?? "N/A")
                    .font(.caption)
                    .foregroundStyle(.white)
                
                Text("Trending")
                    .foregroundStyle(Color.green)
            }
            
            
        }
        .frame(maxWidth: .infinity, maxHeight: 50)
        .padding(5)
    }
}
