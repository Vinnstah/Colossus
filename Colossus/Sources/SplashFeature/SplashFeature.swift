import Foundation
import SwiftUI
import ComposableArchitecture
import SwiftData

@Reducer
public struct SplashFeature {
    @Dependency(\.continuousClock) var clock
    @Dependency(\.userDefaults) var userDefaults
}

extension SplashFeature {
    @ObservableState
    public struct State {
    }
    
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
}


extension SplashFeature {
    public var body: some Reducer<State, Action> {
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
    struct View: SwiftUI.View {
        let store: StoreOf<SplashFeature>
        var body: some SwiftUI.View {
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
