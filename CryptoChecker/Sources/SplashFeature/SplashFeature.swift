import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
public struct SplashFeature {
    @Dependency(\.apiClient) var apiClient
}

extension SplashFeature {
    @ObservableState
    public struct State: Equatable {}
    
    public enum Action: Equatable {
        case onAppear
        case loadSymbols
        case delegate(DelegateAction)
        
        public enum DelegateAction {
            case loadingFinished
        }
    }
}

extension SplashFeature {
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.loadSymbols)
                }
            case .loadSymbols:
                return .run { send in
                    print(try await apiClient.getOrderbook(AssetPair(symbol: .init(to: "USDT", from: "ETH"), limit: 10)))
                    await send(.delegate(.loadingFinished))
                }
            case .delegate(.loadingFinished):
                return .none
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
