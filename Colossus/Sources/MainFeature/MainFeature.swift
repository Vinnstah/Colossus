import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct MainFeature {
    @ObservableState
    struct State {}
    
    enum Action {}
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            }
        }
    }
}

extension MainFeature {
    struct View: SwiftUI.View {
        let store: StoreOf<MainFeature>
        var body: some SwiftUI.View {
            Text("MAIN")
        }
    }
}
