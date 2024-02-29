import SwiftUI
import Foundation
import ComposableArchitecture

@Reducer
public struct AddItem {
    @ObservableState
    public struct State: Equatable {
        var coin: String = ""
        var symbol: String = ""
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            }
        }
    }
    
    public struct View: SwiftUI.View {
        @Bindable var store: StoreOf<AddItem>
        
        public var body: some SwiftUI.View  {
            ZStack {
                Color("Background").ignoresSafeArea()
                VStack {
                    Form {
                        Section("Coin") {
                            TextField("Coin Name", text: $store.coin)
                            TextField("Symbol", text: $store.symbol)
                        }
                    }
                }
            }
            
        }
    }
}
