import Foundation
import SwiftUI
import CryptoServiceUniFFI

struct SymbolItem: View {
    let coin: CoinMeta?
    
    init(coin: CoinMeta? = nil) {
        self.coin = coin
    }
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: coin?.png64 ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
                .frame(width: 25, height: 25)
                
            VStack(alignment: .leading) {
                Text(coin?.name ?? "")
                    .foregroundStyle(Color.white)
                Text((coin?.code ?? coin?.name) ?? "")
                    .foregroundStyle(Color("AccentColor"))
                    .font(.caption)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(coin?.delta?.hour.convertDeltaToDeciamlPercentage() ?? 0, format: .percent)
                    .font(.caption)
                    .foregroundStyle(.white)
                
                Text(coin?.delta?.hour.convertDeltaToDeciamlPercentage() ?? 0 > 0 ? "Trending" : "Declining")
                    .foregroundStyle(((coin?.delta?.hour ?? 0) - 1) > 0 ? Color.green : Color.red)
            }
            
            
        }
        .frame(maxWidth: .infinity, maxHeight: 50)
        .padding(5)
    }
}

extension Double? {
    func convertDeltaToDeciamlPercentage() -> Double {
        (self ?? 1) - 1
    }
}
