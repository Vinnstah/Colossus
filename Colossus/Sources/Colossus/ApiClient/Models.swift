import Foundation
import SwiftUI

public protocol QueryItemsExpressible {
    var queryItems: [URLQueryItem] { get }
}

// MARK: - IncomingOrder
public struct Symbol: Codable, Equatable {
    public let symbolid, exchangeid, symbolType, assetidBase: String?
    public let assetidQuote, dataStart, dataEnd, dataQuoteStart: String?
    public let dataQuoteEnd, dataOrderbookStart, dataOrderbookEnd, dataTradeStart: String?
    public let dataTradeEnd: String?
    public let volume1Hrs, volume1HrsUsd, volume1Day, volume1DayUsd: Double?
    public let volume1Mth, volume1MthUsd, price: Double?
    public let symbolidExchange, assetidBaseExchange, assetidQuoteExchange: String?
    public let pricePrecision, sizePrecision: Double?
    
    enum CodingKeys: String, CodingKey {
        case symbolid = "symbol_id"
        case exchangeid = "exchange_id"
        case symbolType = "symbol_type"
        case assetidBase = "asset_id_base"
        case assetidQuote = "asset_id_quote"
        case dataStart = "data_start"
        case dataEnd = "data_end"
        case dataQuoteStart = "data_quote_start"
        case dataQuoteEnd = "data_quote_end"
        case dataOrderbookStart = "data_orderbook_start"
        case dataOrderbookEnd = "data_orderbook_end"
        case dataTradeStart = "data_trade_start"
        case dataTradeEnd = "data_trade_end"
        case volume1Hrs = "volume_1hrs"
        case volume1HrsUsd = "volume_1hrs_usd"
        case volume1Day = "volume_1day"
        case volume1DayUsd = "volume_1day_usd"
        case volume1Mth = "volume_1mth"
        case volume1MthUsd = "volume_1mth_usd"
        case price
        case symbolidExchange = "symbol_id_exchange"
        case assetidBaseExchange = "asset_id_base_exchange"
        case assetidQuoteExchange = "asset_id_quote_exchange"
        case pricePrecision = "price_precision"
        case sizePrecision = "size_precision"
    }
    
    public init(
        symbolid: String?,
        exchangeid: String?,
        symbolType: String?,
        assetidBase: String?,
        assetidQuote: String?,
        dataStart: String?,
        dataEnd: String?,
        dataQuoteStart: String?,
        dataQuoteEnd: String?,
        dataOrderbookStart: String?,
        dataOrderbookEnd: String?,
        dataTradeStart: String?,
        dataTradeEnd: String?,
        volume1Hrs: Double?,
        volume1HrsUsd: Double?,
        volume1Day: Double?,
        volume1DayUsd: Double?,
        volume1Mth: Double?,
        volume1MthUsd: Double?,
        price: Double?,
        symbolidExchange: String?,
        assetidBaseExchange: String?,
        assetidQuoteExchange: String?,
        pricePrecision: Double?,
        sizePrecision: Double?
    ) {
        self.symbolid = symbolid
        self.exchangeid = exchangeid
        self.symbolType = symbolType
        self.assetidBase = assetidBase
        self.assetidQuote = assetidQuote
        self.dataStart = dataStart
        self.dataEnd = dataEnd
        self.dataQuoteStart = dataQuoteStart
        self.dataQuoteEnd = dataQuoteEnd
        self.dataOrderbookStart = dataOrderbookStart
        self.dataOrderbookEnd = dataOrderbookEnd
        self.dataTradeStart = dataTradeStart
        self.dataTradeEnd = dataTradeEnd
        self.volume1Hrs = volume1Hrs
        self.volume1HrsUsd = volume1HrsUsd
        self.volume1Day = volume1Day
        self.volume1DayUsd = volume1DayUsd
        self.volume1Mth = volume1Mth
        self.volume1MthUsd = volume1MthUsd
        self.price = price
        self.symbolidExchange = symbolidExchange
        self.assetidBaseExchange = assetidBaseExchange
        self.assetidQuoteExchange = assetidQuoteExchange
        self.pricePrecision = pricePrecision
        self.sizePrecision = sizePrecision
    }
}

extension Symbol: QueryItemsExpressible {
    public var queryItems: [URLQueryItem] {
        return []
    }
    
}

public struct AssetPair: Sendable, Hashable, QueryItemsExpressible, Codable {
    
    public let symbol: Symbol
    public var limit: Int?
    
    public var queryItems: [URLQueryItem] {
        var items =  [URLQueryItem(name: "symbol", value: symbol.description)]
        if let limit {
            items.append( .init(name: "limit", value: String(limit)))
        }
        return items
    }
    
    public init(
        symbol: Symbol,
        limit: Int? = nil
    ) {
        self.symbol = symbol
        self.limit = limit
    }
    
    public struct Symbol: Sendable, Hashable, Codable {
        internal init(to: String, from: String) {
            self.to = to
            self.from = from
        }
        
        public let to: String
        public let from: String
        public var description: String {
            return [from, to].joined(separator: "")
        }
    }
}

extension AssetPair {
    
    public init(
        from: String,
        to: String,
        limit: Int?
    ) {
        self.init(symbol: .init(to: to, from: from),
                  limit: limit
        )
    }
}

extension AssetPair {
    public static let listOfAssetPairs: [Self] = [
        AssetPair(symbol: .init(to: "USDT", from: "ETH"), limit: 1),
        AssetPair(symbol: .init(to: "USDT", from: "BTC"), limit: 1),
        AssetPair(symbol: .init(to: "USDT", from: "BNB"), limit: 1),
        AssetPair(symbol: .init(to: "USDT", from: "SOL"), limit: 1),
        AssetPair(symbol: .init(to: "USDT", from: "XRP"), limit: 1),
        AssetPair(symbol: .init(to: "USDT", from: "ADA"), limit: 1)
    ]
}



public struct AnonymousOrderBook: Sendable, Hashable, Codable {
    public struct Order: Sendable, Hashable, Codable, CustomStringConvertible {
        public let price: String
        public let amount: String
        public var description: String {
            "\(amount) @ \(price)"
        }
        
        public var formattedPrice: String {
            String(Double(price) ?? 0)
        }
    }
    public typealias Bids = [Order]
    public typealias Asks = [Order]
    
    public let lastUpdateId: Int
    public let bids: Bids
    public let asks: Asks
    
    public var highestBid: Order? {
        bids.first
    }
    
    public var lowestAsk: Order? {
        asks.first
    }
    
    
}

extension AnonymousOrderBook.Order {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let pair = try container.decode([String].self)
        guard pair.count == 2 else {
            fatalError("Decoding Error, expected a pair")
        }
        self.init(price: pair[0], amount: pair[1])
    }
}

public struct OrderBook: Sendable, Hashable, Codable {
    public let pair: AssetPair
    public let fetchedOrderBook: AnonymousOrderBook
}
extension OrderBook: QueryItemsExpressible {
    public var queryItems: [URLQueryItem] {
        var listOfQueryItems: [URLQueryItem]  = []
        let symbol: URLQueryItem = .init(name: "symbol", value: self.pair.symbol.description)
        listOfQueryItems.append(symbol)
        if self.pair.limit != nil  {
            let limit = URLQueryItem(name: "limit", value: self.pair.limit?.description)
            listOfQueryItems.append(limit)
        }
        return listOfQueryItems
    }
}

extension OrderBook {
    public static let mock: [Self] = [
        Self.init(
            pair: .init(
                from: "BTC",
                to: "USDT",
                limit: 1
            ),
            fetchedOrderBook: .init(
                lastUpdateId: 11,
                bids: [.init(
                    price: "67000",
                    amount: "1"
                )],
                asks: [.init(
                    price: "67001",
                    amount: "2"
                )]
            )
        ),
        Self.init(
            pair: .init(
                from: "ETH",
                to: "USDT",
                limit: 1
            ),
            fetchedOrderBook: .init(
                lastUpdateId: 11,
                bids: [.init(
                    price: "1234",
                    amount: "1"
                )],
                asks: [.init(
                    price: "1233",
                    amount: "2"
                )]
            )
        ),
        Self.init(
            pair: .init(
                from: "SOL",
                to: "USDT",
                limit: 1
            ),
            fetchedOrderBook: .init(
                lastUpdateId: 11,
                bids: [.init(
                    price: "255",
                    amount: "1"
                )],
                asks: [.init(
                    price: "256",
                    amount: "2"
                )]
            )
        ),
        Self.init(
            pair: .init(
                from: "ADA",
                to: "USDT",
                limit: 1
            ),
            fetchedOrderBook: .init(
                lastUpdateId: 11,
                bids: [.init(
                    price: "26.23",
                    amount: "2"
                )],
                asks: [.init(
                    price: "26.25",
                    amount: "11"
                )]
            )
        ),
                                      
    ]
}

//public struct ListOfCoinsRequest: Codable {
//    public let currency: String
//    public let sort: String
//    public let order: String
//    public let offset: UInt8
//    public let limit: UInt32
//    public let meta: Bool
//
//    // Default memberwise initializers are never public by default, so we
//    // declare one manually.
//    public init(
//        currency: String,
//        sort: String,
//        order: String,
//        offset: UInt8,
//        limit: UInt32,
//        meta: Bool
//    ) {
//        self.currency = currency
//        self.sort = sort
//        self.order = order
//        self.offset = offset
//        self.limit = limit
//        self.meta = meta
//    }
//}
//public enum Sort:String, Codable, RawRepresentable {
//    case rank
//    case price
//    case volume
//    case code
//    case name
//    case age
//    
//}
//
//public struct AggregatedCoinInformations: Codable {
//    public let name: String
//    public let symbol: String
//    public let rank: Int64?
//    public let rate: Double
//    public let color: String
//    public let png64: String
//
//    // Default memberwise initializers are never public by default, so we
//    // declare one manually.
//    public init(
//        name: String,
//        symbol: String,
//        rank: Int64?,
//        rate: Double,
//        color: String,
//        png64: String
//    ) {
//        self.name = name
//        self.symbol = symbol
//        self.rank = rank
//        self.rate = rate
//        self.color = color
//        self.png64 = png64
//    }
//}
