import Foundation
import Dependencies
import IdentifiedCollections

public struct DataManager: DependencyKey {
    public typealias FetchUser = () throws -> User?
    public typealias AddUser = (User) throws -> User
    public typealias FetchCoins = () throws -> IdentifiedArrayOf<Coin>?
    public typealias InsertCoin = (Coin) throws -> IdentifiedArrayOf<Coin>?
    public typealias DeleteCoin = (Coin) throws -> IdentifiedArrayOf<Coin>
    
    public var fetchUser: FetchUser
    public var addUser: AddUser
    public var fetchCoins: FetchCoins
    public var inserCoin: InsertCoin
    public var deleteCoin: DeleteCoin
    
    public init(
        fetchUser: @escaping FetchUser,
        addUser: @escaping AddUser,
        fetchCoins: @escaping FetchCoins,
        inserCoin: @escaping InsertCoin,
        deleteCoin: @escaping DeleteCoin
    ) {
        self.fetchUser = fetchUser
        self.addUser = addUser
        self.fetchCoins = fetchCoins
        self.inserCoin = inserCoin
        self.deleteCoin = deleteCoin
    }
}

public extension DataManager {
    
    
    static var liveValue: Self {
        @Dependency(\.userDefaults) var userDefaults
        @Dependency(\.decode) var decode
        @Dependency(\.encode) var encode
        
        return Self(
            fetchUser: {
                guard let data = userDefaults.data(forKey: .user) else {
                    return nil
                }
                return try decode(User.self, from: data)
            },
            addUser: { user in
                let encodedUser = try encode(user)
                userDefaults.set(encodedUser, forKey: .user)
                return user
            },
            fetchCoins: {
                guard let data = userDefaults.data(forKey: .coins) else {
                    return nil
                }
                return try decode(IdentifiedArrayOf<Coin>.self, from: data)
                
            },
            inserCoin: { coin in
                guard let data = userDefaults.data(forKey: .coins) else {
                    return nil
                }
                var coins = try decode(IdentifiedArrayOf<Coin>.self, from: data)
                coins.append(coin)
                
                userDefaults.set(try encode(coins), forKey: .coins)
                return coins
            },
            deleteCoin: { coin in
                guard let data = userDefaults.data(forKey: .coins) else {
                    return []
                }
                var coins = try decode(IdentifiedArrayOf<Coin>.self, from: data)
                coins.remove(id: coin.id)
                userDefaults.set(try encode(coins), forKey: .coins)
                return coins
            }
        )
    }
}

extension DependencyValues {
    public var dataManager: DataManager {
        get { self[DataManager.self] }
        set { self[DataManager.self] = newValue }
    }
}

extension DataManager {
    public static let testValue = Self(
        fetchUser: unimplemented("\(Self.self).fetchUser"),
        addUser: unimplemented("\(Self.self).addUser"),
        fetchCoins: unimplemented("\(Self.self).fetchCoins"),
        inserCoin: unimplemented("\(Self.self).inserCoin"),
        deleteCoin: unimplemented("\(Self.self).deleteCoin")
    )
        
}

fileprivate extension String {
    static let user: String = "User"
    static let coins: String = "Coins"
}

public struct User: Codable, Equatable {
    public let id: UUID
    public let name: String
    
    public init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
}
