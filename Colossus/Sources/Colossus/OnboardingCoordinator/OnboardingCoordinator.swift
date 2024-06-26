import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
public struct OnboardingCoordinator : Sendable{
    @Reducer
    public enum Path {
        case personalInformation(PersonalInformation)
        case wallet(Wallet)
        case customizeHome(CustomizeHome)
        case summary(Summary)
    }
    
    @Dependency(\.dataManager) var dataManager
    
    @ObservableState
    public struct State {
        var path = StackState<Path.State>()
        @Shared var user: User
    }
    
    public enum Action {
        case path(StackAction<Path.State, Path.Action>)
        case beginOnboardingTapped
        case delegate(Delegate)
        
        public enum Delegate {
            case finishedOnboarding(User)
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .path(.element(id: _, action: .personalInformation(.delegate(.next)))):
                state.path.append(.customizeHome(.init(user: state.$user)))
                return .none
            case .beginOnboardingTapped:
                state.path.append(.personalInformation(.init(user: state.$user)))
                return .none
            case .path(.element(id: _, action:  .customizeHome(.delegate(.next)))):
                state.path.append(.summary(.init(user: state.$user)))
                return .none
                
            case .path(.element(id: _, action:  .summary(.delegate(.finishedOnboarding)))):
                return .run { [user = state.user] send in
                    try dataManager.addUser(user)
                    await send(.delegate(.finishedOnboarding(user)))
                }
                
            case .path, .delegate:
                return .none
                
            }
        }
        .forEach(\.path, action: \.path)
    }
    
    struct Screen: View {
        @Bindable var store: StoreOf<OnboardingCoordinator>
        
        var body: some View {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                VStack {
                    Image(systemName: "bitcoinsign.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400, height: 400, alignment: .center)
                        .foregroundStyle(Color.indigo)
                    Button("Begin Onboarding") {
                        store.send(.beginOnboardingTapped)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("Background").ignoresSafeArea())
            } destination: { store in
                switch store.case {
                case let .personalInformation(store):
                    PersonalInformation.Screen(store: store)
                case let .wallet(store):
                    EmptyView()
                case let .customizeHome(store):
                    CustomizeHome.Screen(store: store)
                case let .summary(store):
                    Summary.Screen(store: store)
                }
            }
            .tint(.indigo)
        }
    }
}



// Create new store, do not scope.
@Reducer
public struct Wallet {}

