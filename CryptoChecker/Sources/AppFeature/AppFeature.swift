import ComposableArchitecture
import Foundation
import SwiftUI


@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        @Presents var destination: Destination.State?
    }
    enum Action {
        case destination(PresentationAction<Destination.Action>)
        case onAppear
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .destination(.presented(.splash(.delegate(.loadingFinished)))):
                state.destination = .main(.init())
                return .none
                
            case .destination(_):
                return .none
            case .onAppear:
                state.destination = .splash(.init())
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination()
        }
    }
    
    @Reducer
    struct Destination {
        @ObservableState
        public enum State {
            case splash(SplashFeature.State)
            case main(MainFeature.State)
        }
        
        public enum Action {
            case splash(SplashFeature.Action)
            case main(MainFeature.Action)
        }
        
        public var body: some Reducer<State, Action> {
            Scope(state: \.splash , action: \.splash) {
                SplashFeature()
            }
            Scope(state: \.main , action: \.main) {
                MainFeature()
            }
        }
    }
}

extension AppFeature {
    struct View: SwiftUI.View {
        @Bindable var store: StoreOf<AppFeature>
        
        public var body: some SwiftUI.View {
            NavigationStack {
                MainFeature.View()
                    .task {
                        store.send(.onAppear)
                        
                    }
                    .navigationDestination(
                        item: $store.scope(
                            state: \.destination?.splash,
                            action: \.destination.splash
                        )
                    ) { store in
                        SplashFeature.View(store: store)
                    }
            }
        }
    }
}
