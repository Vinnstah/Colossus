import Foundation
import ComposableArchitecture
import CryptoServiceUniFFI

@Reducer
public struct CoinFeature {
    
    @ObservableState
    public struct State: Equatable {
        let orderBook: OrderBook? 
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
