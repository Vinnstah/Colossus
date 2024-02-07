import Foundation
import SwiftUI
import ComposableArchitecture
import SwiftData

@Reducer
public struct SplashFeature {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.continuousClock) var clock
    @Environment(\.modelContext) private var context
}

extension SplashFeature {
    @ObservableState
    public struct State {
        let dataSource: SymbolDataSource = .shared
        var symbols: [SymbolSwiftData] = []
    }
    
    public enum Action: Equatable {
        case onAppear
        case loadSymbols
        case symbolResult(AnonymousOrderBook)
        case delegate(DelegateAction)
        
        public enum DelegateAction {
            case loadingFinished
        }
    }
}

extension SplashFeature {
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.symbols = state.dataSource.fetchItems()
                print(state.symbols.first!.symbol)
                return .run { send in
                    await send(.loadSymbols)
                }
                
            case .loadSymbols:
                return .run { send in
//                    print(try context.fetch(descriptor))
//                    print(try await apiClient.getOrderbook(AssetPair(symbol: .init(to: "USDT", from: "ETH"), limit: 10)))
//                    await send(.symbolResult(try await apiClient.getOrderbook(AssetPair(symbol: .init(to: "USDT", from: "ETH"), limit: 10))))
//                    try await clock.sleep(for: .milliseconds(800))
                    await send(.delegate(.loadingFinished))
                }
            case .delegate(.loadingFinished):
                return .none
                
            case let .symbolResult(symbol):
                print("1")
//                state.symbols.append(.init(symbol: symbol))
//                state.dataSource.appendItem(item: symbol)
//                state.symbols.forEach({ state.dataSource.appendItem(item: $0) })
//                SymbolDataSource.shared.appendItem(item: .init(symbol: symbol))
//                state.dataSource.appendItem(item: .init(symbol: symbol))
//                print(symbol)
                return .none
            }
            
        }
    }
}

extension SplashFeature {
    
    struct View: SwiftUI.View {
        let store: StoreOf<SplashFeature>
        var body: some SwiftUI.View {
            Text("Loading Colossus...")
                .onAppear(perform: {
                    store.send(.onAppear)
                })
        }
    }
}

final class SymbolDataSource {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    @MainActor
    static let shared = SymbolDataSource()

    @MainActor
    private init() {
        self.modelContainer = try! ModelContainer(for: SymbolSwiftData.self)
        self.modelContext = modelContainer.mainContext
    }

    func appendItem(item: SymbolSwiftData) {
        modelContext.insert(item)
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func fetchItems() -> [SymbolSwiftData] {
        do {
            return try modelContext.fetch(FetchDescriptor<SymbolSwiftData>())
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func removeItem(_ item: SymbolSwiftData) {
        modelContext.delete(item)
    }
}
