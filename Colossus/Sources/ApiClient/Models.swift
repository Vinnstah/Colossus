import Foundation
import SwiftData

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
    
    public init(symbolid: String?, exchangeid: String?, symbolType: String?, assetidBase: String?, assetidQuote: String?, dataStart: String?, dataEnd: String?, dataQuoteStart: String?, dataQuoteEnd: String?, dataOrderbookStart: String?, dataOrderbookEnd: String?, dataTradeStart: String?, dataTradeEnd: String?, volume1Hrs: Double?, volume1HrsUsd: Double?, volume1Day: Double?, volume1DayUsd: Double?, volume1Mth: Double?, volume1MthUsd: Double?, price: Double?, symbolidExchange: String?, assetidBaseExchange: String?, assetidQuoteExchange: String?, pricePrecision: Double?, sizePrecision: Double?) {
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

public struct AnonymousOrderBook: Sendable, Hashable, Codable {
    public struct Order: Sendable, Hashable, Codable, CustomStringConvertible {
        public let price: String
        public let amount: String
        public var description: String {
            "\(amount) @ \(price)"
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
