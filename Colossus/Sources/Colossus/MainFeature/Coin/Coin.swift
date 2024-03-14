import Foundation
import SwiftUI

public struct Coin: Identifiable, Codable, Equatable {
    public typealias ID = UUID
    
    public var id: ID
    public var symbol: String
    public var name: String
    public var base64encodedImage: String
    
    private init(symbol: String, name: String, id: UUID, base64encodedImage: String) {
        self.symbol = symbol
        self.name = name
        self.id = id
        self.base64encodedImage = base64encodedImage
    }
    
    public init(id: ID) {
        self.init(symbol: "", name: "", id: id, base64encodedImage: "")
    }
    
    init(symbol: String, name: String, id: UUID, image: UIImage) {
        self.init(
            symbol: symbol,
            name: name,
            id: id,
            base64encodedImage: Coin.convertImageToBase64(image: image) ?? "")
    }
    
    public static func convertImageToBase64(image: UIImage) -> String? {
        image.jpegData(compressionQuality: 1)?.base64EncodedString()
    }
    
    public static func convertBase64ToImage(base64String: String) -> Image? {
        guard let imageData = Data(base64Encoded: base64String) else {
            return nil
        }
        
        guard let uiImage = UIImage(data: imageData) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
}


