import Foundation
import CryptoServiceUniFFI
import SwiftUI

extension Coin: Identifiable {
    public var id: String {
        self.code ?? ""
    }
}

extension CoinMeta: Identifiable {
    public var id: UUID {
        UUID()
    }
}

extension CoinMeta: @unchecked Sendable {}
extension CoinHistory: @unchecked Sendable {}
