import Foundation
import ComposableArchitecture
import SwiftUI

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
