import Foundation
import ComposableArchitecture
import SwiftUI
import CryptoServiceUniFFI

extension MainFeature.View {
    struct SymbolItem: View {
        let coin: CoinMeta
        
        init(coin: CoinMeta) {
            self.coin = coin
        }
        
        var body: some View {
            HStack {
                AsyncImage(url: URL(string: coin.png64 ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 25, height: 25)
                
                VStack(alignment: .leading) {
                    Text(coin.name ?? "")
                        .foregroundStyle(Color.white)
                    Text(coin.code ?? coin.name ?? "")
                        .foregroundStyle(Color("AccentColor"))
                        .font(.caption)
                }
                
                Spacer()
                deltaDisplay()
            }
            .frame(maxWidth: .infinity, maxHeight: 50)
            .padding(5)
        }
        
        @MainActor
        @ViewBuilder
        func deltaDisplay() -> some View {
            VStack(alignment: .trailing) {
                Text(coin.rate ?? 0, format: .number.precision(.fractionLength(3)))
                    .foregroundStyle(Color.white)
                HStack {
                    Text(
                        coin.delta?.day.convertDeltaToDeciamlPercentage() ?? 0,
                        format: .percent
                    )
                    .font(.caption)
                    .foregroundStyle(.white)
                    
                    Image(
                        systemName: coin.delta?.day.convertDeltaToDeciamlPercentage() ?? 0 > 0 ? "arrow.up.forward" : "arrow.down.right"
                    )
                    .foregroundStyle(((coin.delta?.day ?? 0) - 1) > 0 ? Color.green : Color.red)
                }
            }
        }
    }
}

extension Double? {
    func convertDeltaToDeciamlPercentage() -> Double {
        (self ?? 1) - 1
    }
}
