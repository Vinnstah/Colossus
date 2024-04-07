import SwiftUI
import CryptoServiceUniFFI
import Foundation
import Charts

struct MyAssets: View {
    var assets: [any Asset]
    
    init(assets: [any Asset] = mockableAssets) {
        self.assets = assets
    }
    var body: some View {
        VStack {
            HStack {
                Text("My Assets")
                    .foregroundStyle(Color.white)
                    .padding(.leading, 10)
                Spacer()
            }
            ScrollView(.horizontal) {
                HStack {
                    ForEach(assets, id: \.name) { asset in
                        AssetView(asset: asset)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        
    }
}

struct MockableAsset: Asset, Hashable {
    var name: String
    var ticker: String
    var quantity: String
    var image: Image
    var price: String
    var historicalPrice: [Float]
    
    public init(
        name: String,
        ticker: String,
        quantity: String,
        image: Image,
        price: String,
        historicalPrice: [Float]
    ) {
        self.name = name
        self.ticker = ticker
        self.quantity = quantity
        self.image = image
        self.price = price
        self.historicalPrice = historicalPrice
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }
    
}

extension LinearGradient {
    static let areaGradient = LinearGradient(
            gradient: Gradient (
                colors: [
                    Color.indigo.opacity(0.3),
                    Color.indigo.opacity(0.2),
                    Color.indigo.opacity(0.05),
                    Color.indigo.opacity(0.00)
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
}
struct AssetView: View {
    let asset: any Asset
    
    
    var body: some View {
        ZStack {
            Rectangle()
                .scaledToFit()
                .foregroundStyle(Color("Container"))
                .clipShape(.rect(cornerSize: .init(width: 15, height: 15)))
            VStack {
                Spacer()
                    Chart(0..<asset.historicalPrice.count, id: \.self) {
                        index in
                        LineMark(
                            x: .value("xAxis", index), 
                            y: .value("Price", asset.historicalPrice[index])
                        )
                        .lineStyle(.init(lineWidth: 1.0))
                        .foregroundStyle(Color.indigo)
                        
                        AreaMark(
                            x: .value("xAxis", index),
                            y: .value("Price", asset.historicalPrice[index])
                        )
                        .foregroundStyle(LinearGradient.areaGradient)
                    }
                    .chartLegend(.hidden)
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .chartYScale(domain: asset.historicalPrice.min()!...asset.historicalPrice.max()!)
                    .frame(height: 50, alignment: .bottomTrailing)
            }
            .clipShape(.rect(cornerSize: .init(width: 15, height: 15)))
            VStack {
                HStack {
                    asset.image
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.white)
                    VStack {
                        Text(asset.name)
                            .font(.subheadline)
                            .foregroundStyle(Color.white)
                        Text(asset.ticker)
                            .font(.caption)
                            .foregroundStyle(Color("AccentColor"))
                    }
                    Spacer()
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text(asset.price.description)
                            .font(.subheadline)
                            .foregroundStyle(Color.white)
                        Text("\(Float(asset.price) ?? 0.0 * (Float(asset.quantity) ?? 0.0))")
                            .font(.caption)
                            .foregroundStyle(Color("AccentColor"))
                    }
                }
                Spacer()
            }
            .clipShape(.rect(cornerSize: .init(width: 15, height: 15)))
            .padding(20)
        }
        .frame(width: 150, height: 150, alignment: .center)
    }
}

protocol Asset: Hashable {
    var name: String { get }
    var ticker: String { get }
    var quantity: String { get }
    var image: Image { get }
    var price: String { get }
    var historicalPrice: [Float] { get }
}

extension CoinMeta: Asset {
    var name: String {
        self.symbol ?? ""
    }
    
    var ticker: String {
        self.code ?? ""
    }
    
    var quantity: String {
        return "1"
    }
    
    var image: Image {
        Image(systemName: "cross")
    }
    
    var price: String {
        "\(self.rate ?? 0)"
    }
    
    var historicalPrice: [Float] {
        var prices: [Float] = []
        prices.append(Float(self.delta?.day ?? 0))
        prices.append(Float(self.delta?.week ?? 0))
        prices.append(Float(self.delta?.month ?? 0))
        return prices
    }
    
    
}

let mockableAssets: [MockableAsset] = [
    MockableAsset(
        name: "Blob",
        ticker: "BLB",
        quantity: "1",
        image: Image(systemName: "cross"),
        price: "123",
        historicalPrice: [122, 145.1, 162.25, 112.2, 114, 116]
    ),
    MockableAsset(
        name: "Blob Jr",
        ticker: "BLBJR",
        quantity: "2",
        image: Image(systemName: "square"),
        price: "23",
        historicalPrice: [26, 52, 56, 55, 42, 41]
    ),
    MockableAsset(
        name: "Blob SR",
        ticker: "BLBSR",
        quantity: "3",
        image: Image(systemName: "circle"),
        price: "2351.23",
        historicalPrice: [2341, 2421, 2345, 2445, 2211, 2111]
    ),
    MockableAsset(
        name: "Blob Jr Jr",
        ticker: "JRBLB",
        quantity: "1",
        image: Image(systemName: "car"),
        price: "12.421",
        historicalPrice: [13, 14, 12, 16, 17, 19]
    ),
]

// Naive implementation of conformance. Need to change into Floats and add real data. Re-write all when switching API's
extension OrderBook: Asset {
    var name: String {
        self.pair.symbol.from
    }
    
    var ticker: String {
        self.pair.symbol.from
    }
    
    var quantity: String {
        self.fetchedOrderBook.lowestAsk?.amount ?? "0.0"
    }
    
    var image: Image {
        Image(self.pair.symbol.from)
    }
    
    var price: String {
        self.fetchedOrderBook.lowestAsk?.price ?? "0"
    }
    
    var historicalPrice: [Float] {
        guard let float1 = Float(self.fetchedOrderBook.lowestAsk?.amount ?? "0.0") else {
            return [0]
        }
        guard let float2 = Float(self.fetchedOrderBook.highestBid?.amount ?? "0.0") else {
            return [0]
        }
        return [float1, float2]
    }
    
    
}
