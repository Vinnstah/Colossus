import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
public struct PersonalInformation {
    @ObservableState
    public struct State {
        @Shared var user: User
        var createNewWallet: Bool = false
        var isDisabled: Bool = true
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
                state.isDisabled = false
                return .run { send in
                    try await Task.sleep(for: .milliseconds(350))
                    await send(.delegate(.next))
                }
            case .delegate(.next):
                state.isDisabled = true
                return .none
            case .binding, .delegate:
                return .none
            }
        }
    }
    
    struct Screen: View {
        @Bindable var store: StoreOf<PersonalInformation>
        
        var body: some View {
            VStack {
                Form {
                    Section {
                        TextField("First Name", text: $store.user.firstName)
                            .foregroundStyle(Color("AccentColor"))
                    } header: {
                        Text("First Name")
                            .foregroundStyle(Color.white.opacity(50))
                    }
                    .listRowBackground(Color("Background").opacity(10))
                    
                    Section {
                        TextField("Last Name", text: $store.user.lastName)
                            .foregroundStyle(Color("AccentColor"))
                    } header: {
                        Text("Family Name")
                            .foregroundStyle(Color.white.opacity(50))
                    }
                    .listRowBackground(Color("Background").opacity(10))
                    
                    Section {
                        Toggle(isOn: $store.createNewWallet) {
                            Text("Create new Wallet?")
                                .foregroundStyle(Color("AccentColor"))
                        }
                    } header: {
                        Text("In order to save and track different assets you need a Wallet.")
                            .foregroundStyle(Color.white.opacity(50))
                    }
                    .listRowBackground(Color("Background").opacity(10))
                }
                Button(
                    action: { store.send(.nextButtonTapped) },
                    label: {
                        HStack {
                            Text("Next")
                            Image(systemName: "arrow.right")
                                .offset(x: store.isDisabled ? 0 : 140)
                                .animation(.smooth, value: store.isDisabled)
                        }
                        .frame(maxWidth: .infinity)
                    })
                .padding(25)
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .setFormBackground()
            .navigationTitle("Personal Information")
        }
    }
}


#Preview {
    PersonalInformation.Screen(store:
            .init(
                initialState: PersonalInformation.State.init(
                    user: Shared(
                        User.init(id: .init(), firstName: "Blob", lastName: "McBlob", topics: [.crypto])))) {
                            PersonalInformation()
                        }
    )
    
}
extension View {
    @ViewBuilder
    func setFormBackground() -> some View {
        self
            .scrollContentBackground(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.ignoresSafeArea())
    }
}
