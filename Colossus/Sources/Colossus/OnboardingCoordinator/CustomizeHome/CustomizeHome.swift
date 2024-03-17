import SwiftUI
import Foundation
import ComposableArchitecture

@Reducer
public struct CustomizeHome {
    @ObservableState
    public struct State {
        @Shared var user: User
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
        @Bindable var store: StoreOf<CustomizeHome>
        
        var body: some View {
            Form {
                Section {
                    VStack {
                        Text("Customize HomeScreen")
                    }
                }
                Section {
                    ForEach(User.Topic.allCases) { topic in
                            Toggle(isOn: $store.user.topics.isOn(topic)) {
                                Text(topic.rawValue)
                                
                            }
                    }
                } header: {
                    Text("Select topics")
                        .foregroundStyle(Color.indigo.opacity(50))
                }
                Section {
                    Button("Next") {
                        store.send(.nextButtonTapped)
                    }
                }
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
