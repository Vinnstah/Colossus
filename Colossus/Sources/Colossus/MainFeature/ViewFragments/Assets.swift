import SwiftUI
import Foundation

struct MyAssets: View {
    var assets: [any Asset] = mockableAssets
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
        }
        
    }
}

struct MockableAsset: Asset, Hashable {
    var name: String
    
    var ticker: String
    
    var quantity: Float
    
    var image: Image
    
    var price: Float
    
    public init(name: String, ticker: String, quantity: Float, image: Image, price: Float) {
        self.name = name
        self.ticker = ticker
        self.quantity = quantity
        self.image = image
        self.price = price
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }
    
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
                        Text("\(asset.price * asset.quantity)")
                            .font(.caption)
                            .foregroundStyle(Color("AccentColor"))
                    }
                }
                Spacer()
            }
            .padding(25)
        }
        .frame(width: 150, height: 150, alignment: .center)
    }
}

protocol Asset: Hashable {
    var name: String { get }
    var ticker: String { get }
    var quantity: Float { get }
    var image: Image { get }
    var price: Float { get }
}

let mockableAssets: [MockableAsset] = [
    MockableAsset(name: "Blob", ticker: "BLB", quantity: 1, image: Image(systemName: "cross"), price: 123),
    MockableAsset(name: "Blob Jr", ticker: "BLBJR", quantity: 2, image: Image(systemName: "square"), price: 23),
    MockableAsset(name: "Blob SR", ticker: "BLBSR", quantity: 3, image: Image(systemName: "circle"), price: 2351.23),
    MockableAsset(name: "Blob Jr Jr", ticker: "JRBLB", quantity: 1, image: Image(systemName: "car"), price: 12.421),
]
