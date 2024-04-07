import Foundation
import Charts
import CryptoServiceUniFFI
import SwiftUI
import ComposableArchitecture

extension CoinFeature {
    public struct View: SwiftUI.View  {
        let store: StoreOf<CoinFeature>
        
        public var body: some SwiftUI.View  {
            Text(store.coin.name ?? "")
                .font(.headline)
            Form {
                Section("Price") {
                    HistoricalGraph(history: store.coin.history ?? [])
                }
                
            }
        }
    }
}

struct HistoricalGraph: View {
    let history: [History]
    var body: some View {
        VStack {
            Spacer()
            Chart(0..<history.count, id: \.self) {
                index in
                LineMark(
                    x: .value("xAxis", history[index].date ?? 0),
                    y: .value("Price", history[index].rate ?? 0)
                )
                .lineStyle(.init(lineWidth: 1.0))
                .foregroundStyle(Color.indigo)
                
                AreaMark(
                    x: .value("xAxis", history[index].date ?? 0),
                    y: .value("Price", history[index].rate ?? 0)
                )
                .foregroundStyle(LinearGradient.areaGradient)
            }
            .chartLegend(.hidden)
            //            .chartXAxis(.hidden)
            //            .chartYAxis(.hidden)
            
            // Horrendous code, please clean up these two.
            .chartYScale(
                domain: (
                    ((history.sorted(by: { $0.rate! < $1.rate!}).first?.rate!
                     )!
                    )...(history.sorted(by: { $0.rate! < $1.rate!}).last?.rate)!
                )
            )
            .chartXScale(domain: (history[0].date ?? 0)...(history[history.count - 1].date ?? 0))
            .frame(height: 200, alignment: .bottomTrailing)
        }
    }
}
