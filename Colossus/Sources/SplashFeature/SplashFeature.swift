import Foundation
import SwiftUI
import ComposableArchitecture
import SwiftData

@Reducer
public struct SplashFeature {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.continuousClock) var clock
    @Dependency(\.userDefaults) var userDefaults
}

extension SplashFeature {
    @ObservableState
    public struct State {
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadSymbols
        case symbolResult(AnonymousOrderBook)
        case delegate(DelegateAction)
        case userOnboarded(Bool)
        
        public enum DelegateAction: Equatable {
            case loadingFinished(onboarded: Bool)
        }
    }
}

extension SplashFeature {
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.userOnboarded(userDefaults.bool(forKey: .userOnboarded) ?? false))
                }
                
            case .loadSymbols:
                return .run { send in
                    Task {
                        print(try await apiClient.getSymbols())
                    }
                    //                    print(try await apiClient.getOrderbook(AssetPair(symbol: .init(to: "USDT", from: "ETH"), limit: 10)))
                    //                    await send(.symbolResult(try await apiClient.getOrderbook(AssetPair(symbol: .init(to: "USDT", from: "ETH"), limit: 10))))
                    try await clock.sleep(for: .milliseconds(1500))
                    await send(.delegate(.loadingFinished(onboarded: false)))
                }
            case let .symbolResult(symbol):
                return .none
                
            case let .userOnboarded(onboardedStatus):
                switch onboardedStatus {
                case true:
                    return .run { send in
                        await send(.delegate(.loadingFinished(onboarded: true)))
                    }
                case false:
                    return .run { send in
                        await send(.loadSymbols)
                    }
                }
            case .delegate:
                return .none
            }
            
        }
    }
}

extension SplashFeature {
    
    struct View: SwiftUI.View {
        let store: StoreOf<SplashFeature>
        var body: some SwiftUI.View {
            Text("Loading Colossus...")
                .onAppear(perform: {
                    store.send(.onAppear)
                })
        }
    }
}

extension String {
    static let userOnboarded: String = "userOnboarded"
}
