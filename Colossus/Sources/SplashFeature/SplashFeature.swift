import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
public struct SplashFeature {
    @Dependency(\.continuousClock) var clock
    @Dependency(\.dataManager) var dataManager
    
    public struct State {}
    
    public enum Action: ViewAction {
        case delegate(DelegateAction)
        case view(View)
        
        public enum View {
            case onAppear
        }
        
        public enum DelegateAction: Equatable {
            case isLoggedIn(User?)
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .view(.onAppear):
                    .run { send in
                        try await clock.sleep(for: .milliseconds(1600))
                        await send(.delegate(.isLoggedIn(try dataManager.fetchUser())))
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
            Image("Colossus")
                .ignoresSafeArea()
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
