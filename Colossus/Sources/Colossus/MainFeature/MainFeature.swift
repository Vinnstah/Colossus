import Foundation
import SwiftUI
import ComposableArchitecture
import IdentifiedCollections
import CryptoServiceUniFFI

@Reducer
public struct MainFeature : Sendable{
    @Dependency(\.uuid) var uuid
    @Dependency(\.rustGateway) var rustGateway
    @Dependency(\.dataManager) var dataManager
    
    @Reducer(state: .equatable)
    public enum Path {
        case coin(CoinFeature)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        @Presents var alert: AlertState<MainFeature.Action.Alert>?
        public var path = StackState<Path.State>()
        public var coins: IdentifiedArrayOf<CoinMeta> = []
        let user: User
        var selectedTopic: User.Topic = .crypto
        
        var timeInterval: TimeIntervalMilliseconds = .day
        var isExpandingCryptoScrollView: Bool = false
    }
    
    public enum Action: ViewAction, Sendable, BindableAction {
        case binding(BindingAction<State>)
        case alert(PresentationAction<Alert>)
        case listOfCoinsResult(Result<[CoinMeta], Swift.Error>)
        case coinHistoryResult(Result<CoinHistory, Swift.Error>)
        case view(View)
        case path(StackAction<Path.State, Path.Action>)
        case delegate(Delegate)
        
        public enum Alert: Equatable, Sendable {
            case dissmissed
            case retry
        }
        
        public enum View : Sendable{
            case onAppear
            case seeAllTapped
            case inspectCoinTapped(CoinMeta)
            case logOutTapped
        }
        
        public enum Delegate: Equatable, Sendable {
            case logOut
        }
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce {
            state,
            action in
            switch action {
                
            case .view(.onAppear):
                return .run { send in
                    
                    //                    await withThrowingTaskGroup(of: Void.self) { group in
                    //                        for assetPair in symbols {
                    //                            group.addTask {
                    //                    let result = await Result {
                    //                        try await self.rustGateway.getListOfCoins()
                    //                        //                                    try await self.rustGateway.getCoinMetaInfo(assetPair.symbol.from)
                    //                    }
                    await send(
                        .listOfCoinsResult(
                            await Result {
                                try await self.rustGateway.getListOfCoins()
                            }
                        )
                    )
                }
                
            case .view(.seeAllTapped):
                state.isExpandingCryptoScrollView.toggle()
                return .none
                
            case let .listOfCoinsResult(.success(coins)):
                state.coins.append(contentsOf: coins)
                return .none
                
            case let .listOfCoinsResult(.failure(error)):
#if DEBUG
                //                state.orderBooks = OrderBook.mock
                
#else
                state.alert = AlertState {
                    TextState("Alert!")
                } actions: {
                    ButtonState(action: .send(.retry)) {
                        TextState("Try Again")
                    }
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
#endif
                
                return .none
                
            case .alert(.presented(.retry)):
                state.alert = nil
                return .run { send in
                    await send(.view(.onAppear)) }
                
            case .alert,
                    .path:
                return .none
                
            case let .view(.inspectCoinTapped(coin)):
                return .run { [state = state] send in
                    await send(
                        .coinHistoryResult(
                            await Result {
                                try await self.rustGateway.getCoinHistory(
                                    .init(
                                        currency: "USD",
                                        code: coin.code ?? "",
                                        start: UInt64(Date().millisecondsSince1970) - state.timeInterval.rawValue,
                                        end: UInt64(Date().millisecondsSince1970),
                                        meta: true
                                    )
                                )
                            }
                        )
                    )
                    
                }
            case let .coinHistoryResult(.success(coinMeta)):
                state.path.append(.coin(.init(coin: coinMeta)))
                return.none
                
            case .coinHistoryResult(.failure):
                return .none
            case .binding, .delegate:
                return .none
            case .view(.logOutTapped):
                return .run { send in
                    try dataManager.logOutUser()
                    
                    await send(.delegate(.logOut))
                }
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension Date {
    var millisecondsSince1970:Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

enum TimeIntervalMilliseconds: UInt64, Hashable, CaseIterable {
    case day = 864_000_00
    case week = 604_800_000
    case month = 262_974_300_0
    case year = 315_569_260_00
    
    var descrition: String {
        switch self {
        case .day:
            "Day"
        case .week:
            "Week"
        case .month:
            "Month"
        case .year:
            "Year"
        }
    }
}

