import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
public struct SplashFeature {
    @Dependency(\.continuousClock) var clock
    @Dependency(\.userDefaults) var userDefaults
    
    public struct State {}
    
    public enum Action: ViewAction {
        case delegate(DelegateAction)
        case view(View)
        
        public enum View {
            case onAppear
        }
        
        public enum DelegateAction: Equatable {
            case isLoggedIn(Bool)
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .view(.onAppear):
                    .run { send in
                        try await clock.sleep(for: .milliseconds(800))
                        let isLoggedIn = userDefaults.bool(forKey: .userOnboarded) ?? false
                        await send(.delegate(.isLoggedIn(isLoggedIn)))
                    }
                
            case .delegate:
                    .none
            }
        }
    }
}

extension SplashFeature {
        @ViewAction(for: SplashFeature.self)
    public struct SplashView: View {
        public let store: StoreOf<SplashFeature>
        public var body: some View {
            Text("Loading Colossus...")
                .onAppear {
                    send(.onAppear)
                }
        }
    }
}

extension String {
    static let userOnboarded: String = "userOnboarded"
}
