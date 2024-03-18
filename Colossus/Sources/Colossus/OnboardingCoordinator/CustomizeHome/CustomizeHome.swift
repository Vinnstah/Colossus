import SwiftUI
import Foundation
import ComposableArchitecture

@Reducer
public struct CustomizeHome {
    @ObservableState
    public struct State {
        @Shared var user: User
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
        @Bindable var store: StoreOf<CustomizeHome>
        
        var body: some View {
            VStack {
                Form {
                    Section {
                        ForEach(User.Topic.allCases) { topic in
                            Toggle(isOn: $store.user.topics.isOn(topic)) {
                                Text(topic.rawValue)
                                    .foregroundStyle(Color("AccentColor"))
                            }
                        }
                    } header: {
                        Text("Select topics")
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
            }
            .setFormBackground()
            .navigationTitle("Topics")
        }
    }
}

extension Binding {
    func isOn<T>(_ value: T) -> Binding<Bool> where Value == Set<T> {
        Binding<Bool>(
            get: {
                self.wrappedValue.contains(value)
            },
            set: {
                if $0 {
                    self.wrappedValue.insert(value)
                } else {
                    self.wrappedValue.remove(value)
                }
            }
        )
    }
}
