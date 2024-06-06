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
        case onboarding(OnboardingCoordinator.State)
        
        public init() {
            self = .splash(SplashFeature.State())
        }
    }
    
    public enum Action {
        case splash(SplashFeature.Action)
        case main(MainFeature.Action)
        case onboarding(OnboardingCoordinator.Action)
    }
    
    public var body: some Reducer<State, Action> {
        Scope(state: \.splash , action: \.splash) {
            SplashFeature()
        }
        Scope(state: \.main , action: \.main) {
            MainFeature()
        }
        Scope(state: \.onboarding , action: \.onboarding) {
            OnboardingCoordinator()
        }
        
        Reduce { state, action in
            switch action {
                
            case let .splash(.delegate(.isLoggedIn(maybeUser))):
                guard let existingUser = maybeUser else {
                    state = .onboarding(.init(user: Shared(User(id: .init(), firstName: "", lastName: "", topics: []))))
                    return .none
                }
                state = .main(MainFeature.State(user: existingUser))
                return .none
                
            case let .onboarding(.delegate(.finishedOnboarding(user))):
                state = .main(MainFeature.State(user: user))
                return .none
                
            case .main(.delegate(.logOut)):
                state = .onboarding(.init(user: Shared(User(id: .init(), firstName: "", lastName: "", topics: []))))
                return .none
                
            case .splash, .main, .onboarding:
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
            ZStack {
                Color("Background").ignoresSafeArea()
                VStack {
                    switch store.state {
                    case .splash:
                        if let store = store.scope(state: \.splash, action: \.splash) {
                            SplashFeature.SplashView(store: store)
                        }
                    case .main:
                        if let store = store.scope(state: \.main, action: \.main) {
                            MainFeature.View(store: store)
                        }
                    case .onboarding:
                        if let store = store.scope(state: \.onboarding, action: \.onboarding) {
                            OnboardingCoordinator.Screen(store: store)
                        }
                    }
                }
            }
        }
    }
}


