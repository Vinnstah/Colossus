import SwiftUI
import Foundation
import ComposableArchitecture

@Reducer
public struct Summary {
    @ObservableState
    public struct State {
        @Shared var user: User
        var hasTappedFinishedOnboarding: Bool = false
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
                
            case .finishOnboardingTapped:
                state.hasTappedFinishedOnboarding = true
                return .run { send in
                    try await Task.sleep(for: .milliseconds(350))
                    await send(.delegate(.finishedOnboarding))
                }
            case .delegate:
                return .none
            }
        }
    }
        
        struct Screen: View {
            let store: StoreOf<Summary>
            
            var body: some View {
                VStack {
                    Form {
                        Section {
                            Text(store.user.firstName)
                                .foregroundStyle(Color("AccentColor"))
                            Text(store.user.lastName)
                                .foregroundStyle(Color("AccentColor"))
                        } header: {
                            Text("Personal Information")
                                .foregroundStyle(Color.white.opacity(50))
                        }
                        .listRowBackground(Color("Background").opacity(10))
                        Section {
                            ForEach(store.user.topics.sorted(by: { $0.rawValue < $1.rawValue})) { topic in
                                Text(topic.rawValue)
                                    .foregroundStyle(Color("AccentColor"))
                            }
                        } header: {
                            Text("Topics")
                                .foregroundStyle(Color.white.opacity(50))
                        }
                        .listRowBackground(Color("Background").opacity(10))
                    }
                    Button(
                        action: { store.send(.finishOnboardingTapped) },
                        label: {
                            HStack {
                                Text("Create User")
                                Image(systemName: store.hasTappedFinishedOnboarding ? "checkmark.circle" : "person.crop.circle.badge.plus" )
                                    .animation(.smooth, value: store.hasTappedFinishedOnboarding)
                            }
                            .frame(maxWidth: .infinity)
                        })
                    .padding(25)
                    .buttonStyle(.borderedProminent)
                }
                .setFormBackground()
                .navigationTitle("Summary")
            }
        }
    }
