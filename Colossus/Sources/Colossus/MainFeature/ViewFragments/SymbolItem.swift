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
        //        VStack {
        //            ZStack {
        //                Capsule(style: .continuous)
        //                    .tint(.indigo)
        //                    .shadow(color: .indigo.opacity(50), radius: 2)
        ////                    .padding(5)
        //                //            Text(orderBook.bids.first?.first ?? "N/A")
        //                //                                .font(.caption)
        //                //                                .foregroundStyle(.white)
        //                //            Text(orderBook.asks.first?.first ?? "N/A")
        //                //                                .font(.caption)
        //                //                                .foregroundStyle(.white)
        //                HStack(alignment: .firstTextBaseline, spacing: 10) {
        //                    Image(orderBook.pair.symbol.from)
        //                        .resizable()
        //                        .frame(width: 25, height: 25)
        //                    Text(orderBook.pair.symbol.from.description)
        //                        .font(.title2)
        //                        .foregroundStyle(.white)
        //                    Spacer()
        //                    Text(orderBook.fetchedOrderBook.highestBid?.formattedPrice ?? "N/A")
        //                        .font(.caption)
        //                        .foregroundStyle(.white)
        //                    Text(orderBook.fetchedOrderBook.lowestAsk?.formattedPrice ?? "N/A")
        //                        .font(.caption)
        //                        .foregroundStyle(.white)
        //                }
        //                .padding(.horizontal, 10)
        //                .padding(.vertical, 5)
        //            }
        //        }
        .frame(maxWidth: .infinity, maxHeight: 50)
        .padding(5)
    }
}
