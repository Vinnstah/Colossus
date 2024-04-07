import Foundation
import ComposableArchitecture
import CryptoServiceUniFFI

@Reducer
public struct CoinFeature {
    
    @ObservableState
    public struct State: Equatable {
        let coin: CoinHistory
    }
    
    public enum Action {
        
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            }
        }
    }
}
