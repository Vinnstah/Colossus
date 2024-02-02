import Foundation
import SwiftUI
import ComposableArchitecture
//import ApiClient

@Reducer
struct SplashFeature {
    @Dependency(\.apiClient) var apiClient
}

extension SplashFeature {
    @ObservableState
    struct State: Equatable {}
    
    enum Action: Equatable {
        case onAppear
        case loadSymbols
    }
}

extension SplashFeature {
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.loadSymbols)
                }
            case .loadSymbols:
                return .run { send in
                    print(try await apiClient.getOrderbook(AssetPair(symbol: .init(to: "USDT", from: "ETH"), limit: 10)))
                }
            }
            
        }
    }
}

extension SplashFeature {
    
    struct View: SwiftUI.View {
        let store: StoreOf<SplashFeature>
        var body: some SwiftUI.View {
            Text("LOADING")
                .onAppear(perform: {
                    store.send(.onAppear)
                })
        }
    }
}
