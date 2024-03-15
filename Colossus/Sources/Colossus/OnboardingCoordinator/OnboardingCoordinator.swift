import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
public struct OnboardingCoordinator {
    @Reducer
    public enum Path {
        case personalInformation(PersonalInformation)
        case wallet(Wallet)
        case customizeHome(CustomizeHome)
    }
    
    @ObservableState
    public struct State {
        var path = StackState<Path.State>()
        @Shared var user: User
    }
    
    public enum Action {
        case path(StackAction<Path.State, Path.Action>)
        case beginOnboardingTapped
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .path(.element(id: _, action: .personalInformation(.delegate(.next)))):
                state.path.append(.wallet(.init()))
                return .none
            case .beginOnboardingTapped:
                state.path.append(.personalInformation(.init(user: state.$user)))
                return .none
            case .path:
                return .none
                
            }
        }
        .forEach(\.path, action: \.path)
    }
    
    struct Screen: View {
        @Bindable var store: StoreOf<OnboardingCoordinator>
        
        var body: some View {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                Button("Begin Onboarding") {
                    store.send(.beginOnboardingTapped)
                }
            } destination: { store in
                switch store.case {
                case let .personalInformation(store):
                    PersonalInformation.Screen(store: store)
                case let .wallet(store):
                    EmptyView()
                case let .customizeHome(store):
                    EmptyView()
                }
            }
            .tint(.indigo)
        }
    }
}
    
    @Reducer
    public struct PersonalInformation {
        @ObservableState
        public struct State {
            @Shared var user: User
            var createNewWallet: Bool = false
        }
        
        public enum Action: BindableAction {
            case binding(BindingAction<State>)
            case nextButtonTapped
            case delegate(Delegate)
            
            public enum Delegate {
                case next
            }
        }
        
        public var body: some ReducerOf<Self> {
            BindingReducer()
            Reduce { state, action in
                switch action {
                case .nextButtonTapped:
                    return .send(.delegate(.next))
                case .binding, .delegate:
                    return .none
                }
            }
        }
        
        struct Screen: View {
            @Bindable var store: StoreOf<PersonalInformation>
            
            var body: some View {
                Form {
                    Section {
                        TextField("First Name", text: $store.user.firstName)
                        TextField("Last Name", text: $store.user.lastName)
                    }
                    Section {
                        Toggle(isOn: $store.createNewWallet) {
                            Text("Create new Wallet?")
                        }
                        Button("Next") {
                            store.send(.nextButtonTapped)
                        }
                    }
                }
            }
        }
    }
    
    @Reducer
    public struct Wallet {}
    
    @Reducer
    public struct CustomizeHome {}
