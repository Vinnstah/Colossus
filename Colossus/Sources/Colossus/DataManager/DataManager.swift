import Foundation
import Dependencies
import IdentifiedCollections
import SwiftUI

public struct DataManager: DependencyKey, Sendable {
    public typealias FetchUser = () throws -> User?
    public typealias AddUser = (User) throws -> User
    public typealias LogOutUser = () throws -> ()
    //    public typealias FetchCoins = () throws -> IdentifiedArrayOf<Coin>?
    //    public typealias InsertCoin = (Coin) throws -> IdentifiedArrayOf<Coin>?
    //    public typealias DeleteCoin = (Coin) throws -> IdentifiedArrayOf<Coin>
    
    public var fetchUser: FetchUser
    public var addUser: AddUser
    public var logOutUser: LogOutUser
    //    public var fetchCoins: FetchCoins
    //    public var insertCoin: InsertCoin
    //    public var deleteCoin: DeleteCoin
    
    public init(
        fetchUser: @escaping FetchUser,
        addUser: @escaping AddUser,
        logOutUser: @escaping LogOutUser
        //        fetchCoins: @escaping FetchCoins,
        //        insertCoin: @escaping InsertCoin,
        //        deleteCoin: @escaping DeleteCoin
    ) {
        self.fetchUser = fetchUser
        self.addUser = addUser
        self.logOutUser = logOutUser
        //        self.fetchCoins = fetchCoins
        //        self.insertCoin = insertCoin
        //        self.deleteCoin = deleteCoin
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
            }, logOutUser: {
                userDefaults.removeValue(forKey: .user)
            }
            //            ,
            //            fetchCoins: {
            //                guard let data = userDefaults.data(forKey: .coins) else {
            //                    return nil
            //                }
            //                return try decode(IdentifiedArrayOf<Coin>.self, from: data)
            //                
            //            },
            //            insertCoin: { coin in
            //                guard let data = userDefaults.data(forKey: .coins) else {
            //                    return nil
            //                }
            //                var coins = try decode(IdentifiedArrayOf<Coin>.self, from: data)
            //                coins.append(coin)
            //                
            //                userDefaults.set(try encode(coins), forKey: .coins)
            //                return coins
            //            },
            //            deleteCoin: { coin in
            //                guard let data = userDefaults.data(forKey: .coins) else {
            //                    return []
            //                }
            //                var coins = try decode(IdentifiedArrayOf<Coin>.self, from: data)
            //                coins.remove(id: coin.id)
            //                userDefaults.set(try encode(coins), forKey: .coins)
            //                return coins
            //            }
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
        logOutUser: unimplemented("\(Self.self).logOutUser")
        //        fetchCoins: unimplemented("\(Self.self).fetchCoins"),
        //        insertCoin: unimplemented("\(Self.self).insertCoin"),
        //        deleteCoin: unimplemented("\(Self.self).deleteCoin")
    )
    
}

fileprivate extension String {
    static let user: String = "User"
    static let coins: String = "Coins"
    static let wallet: String = "Wallet"
}

public struct User: Codable, Equatable, Sendable {
    public let id: UUID
    public var firstName: String
    public var lastName: String
    public var topics: Set<Topic>
    
    public init(id: UUID, firstName: String, lastName: String, topics: Set<Topic>) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.topics = topics
    }
    
    public enum Topic: String, Identifiable, CaseIterable, Codable {
        case crypto = "Crypto"
        case currency = "Currency"
        case interestRates = "Interest Rates"
        case stocks = "Stocks"
        public var id: Self { self }
    }
}
