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
    public var insertCoin: InsertCoin
    public var deleteCoin: DeleteCoin
    
    public init(
        fetchUser: @escaping FetchUser,
        addUser: @escaping AddUser,
        fetchCoins: @escaping FetchCoins,
        insertCoin: @escaping InsertCoin,
        deleteCoin: @escaping DeleteCoin
    ) {
        self.fetchUser = fetchUser
        self.addUser = addUser
        self.fetchCoins = fetchCoins
        self.insertCoin = insertCoin
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
            insertCoin: { coin in
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
        insertCoin: unimplemented("\(Self.self).insertCoin"),
        deleteCoin: unimplemented("\(Self.self).deleteCoin")
    )
        
}

fileprivate extension String {
    static let user: String = "User"
    static let coins: String = "Coins"
    static let wallet: String = "Wallet"
}

public struct User: Codable, Equatable {
    public let id: UUID
    public var firstName: String
    public var lastName: String
    public var topics: [Topics]
    
    public init(id: UUID, firstName: String, lastName: String, topics: [Topics]) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.topics = topics
    }
    
    public enum Topics: Codable {
        case crypto
        case stocks
        case rawmaterials
        case interests
    }
}
