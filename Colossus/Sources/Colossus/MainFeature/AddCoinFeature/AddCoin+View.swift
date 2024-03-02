import SwiftUI
import Foundation
import ComposableArchitecture
import PhotosUI

extension AddCoin {
    public struct View: SwiftUI.View {
        @Bindable var store: StoreOf<AddCoin>
        
        public var body: some SwiftUI.View  {
            ZStack {
                Color("Background").ignoresSafeArea()
                
                VStack {
                    PhotosPicker(selection: $store.selectedImage,
                                 matching: .images) {
                        Text("Select Photos")
                            .font(.largeTitle)
                            .foregroundStyle(.blue)
                    }
                    
                    store.image?
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                    
                        VStack {
                            
                                TextField("Coin Name", text: $store.coin.name)
                                .foregroundStyle(.blue)
                            
                                TextField("Symbol", text: $store.coin.symbol)
                                .foregroundStyle(.blue)
                    }
                }
                .onChange(of: store.selectedImage) {
                    store.send(.convertToImage)
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            store.send(.save)
                        }
                    }
                }
            }
        }
    }
}
