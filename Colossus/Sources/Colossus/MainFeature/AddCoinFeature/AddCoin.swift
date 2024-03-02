import SwiftUI
import Foundation
import ComposableArchitecture
import PhotosUI

@Reducer
public struct AddCoin {
    @Dependency(\.dataManager) var dataManager
    
    @ObservableState
    public struct State: Equatable {
        var coin: Coin
        var selectedImage: PhotosPickerItem? = nil
        var image: Image? = nil
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case convertToImage
        case imageResult(Image)
        case save
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .convertToImage:
                return .run { [image = state.selectedImage] send in
                    await send(.imageResult(
                        try await image?.loadTransferable(
                            type: Image.self) ?? Image(systemName: "cross")
                    ))
                }
                
            case let .imageResult(image):
                state.image = image
                return .none
                
            case .save:
                
                return .run { [coin = state.coin] send in
                    try dataManager.insertCoin(coin)
                }
            }
        }
    }
}
