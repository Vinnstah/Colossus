import ComposableArchitecture
import Foundation
import SwiftUI


@Reducer
public struct AppFeature {
    public init() {}
    
    @ObservableState
    public enum State {
        case splash(SplashFeature.State)
        case main(MainFeature.State)
        
        public init() {
            self = .splash(SplashFeature.State())
        }
    }
    
    public enum Action {
        case splash(SplashFeature.Action)
        case main(MainFeature.Action)
    }
    
    public var body: some Reducer<State, Action> {
        Scope(state: \.splash , action: \.splash) {
            SplashFeature()
        }
        Scope(state: \.main , action: \.main) {
            MainFeature()
        }
        
        Reduce { state, action in
            switch action {
                
            case let .splash(.delegate(.isLoggedIn(isLoggedIn))):
                precondition(isLoggedIn == nil, "Onboarding not yet implemented")
                state = .main(MainFeature.State())
                return .none
                
            case .splash, .main:
                return .none
            }
        }
    }
}

extension AppFeature {
    public struct View: SwiftUI.View {
        public let store: StoreOf<AppFeature>
        
        public init(store: StoreOf<AppFeature>) {
            self.store = store
        }
        
        public var body: some SwiftUI.View {
            switch store.state {
            case .splash:
                if let store = store.scope(state: \.splash, action: \.splash) {
                    SplashFeature.SplashView(store: store)
                }
            case .main:
                if let store = store.scope(state: \.main, action: \.main) {
                    MainFeature.View(store: store)
                }
            }
        }
    }
}


