import SwiftUI
import Foundation
import ComposableArchitecture

@Reducer
public struct Summary {
    @ObservableState
    public struct State {
        @Shared var user: User
    }
    
    public enum Action {
        case delegate(Delegate)
        case finishOnboardingTapped
        
        public enum Delegate {
            case finishedOnboarding
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .delegate:
                return .none
            case .finishOnboardingTapped:
                return .send(.delegate(.finishedOnboarding))
            }
        }
    }
    
    
    struct Screen: View {
        let store: StoreOf<Summary>
        
        var body: some View {
            Form {
                Section {
                        Text(store.user.firstName)
                        Text(store.user.lastName)
                } header: {
                    Text("Personal Information")
                }
                Section {
//                    ForEach(store.user.topics.sorted(by: $0.rawValue < $1.rawValue)) { topic in
//                        Text(topic.rawValue)
//                    }
                } header: {
                    Text("Topics")
                }
                Section {
                    Button("Finish Onboarding") {
                        store.send(.finishOnboardingTapped)
                    }
                }
            }
            .navigationTitle("Summary")
        }
    }
}
