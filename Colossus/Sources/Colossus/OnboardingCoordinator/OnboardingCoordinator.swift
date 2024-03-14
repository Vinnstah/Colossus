import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct OnboardingCoordinator {
    @Reducer
    enum Path {
        case personalInformation(PersonalInformation)
        case wallet(Wallet)
        case customizeHome(CustomizeHome)
    }
    
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        @Shared var user: User
    }
    
    enum Action {
        case path(StackAction<Path.State, Path.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .path(.element(id: _, action: .personalInformation(.delegate(.next)))):
                state.path.append(.wallet(.init()))
                return .none
            case .path:
                return .none
                
            }
        }
        .forEach(\.path, action: \.path)
    }
    
    struct Screen: View {
        let store: StoreOf<OnboardingCoordinator>
        
        var body: some View {
            Text("Onboarding")
        }
    }
}

@Reducer
struct PersonalInformation {
    @ObservableState
    struct State {
        @Shared var user: User
        var createNewWallet: Bool = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case nextButtonTapped
        case delegate(Delegate)
        
        enum Delegate {
            case next
        }
    }
    
    var body: some ReducerOf<Self> {
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
struct Wallet {}

@Reducer
struct CustomizeHome {}
