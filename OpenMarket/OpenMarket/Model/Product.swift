import Foundation

struct Product: Decodable, Hashable {
    var identification: Int
    var vendorIdentification: Int
    var name: String
    var description: String?
    var thumbnail: String
    var currency: Currency
    var price: Decimal
    var bargainPrice: Decimal
    var discountedPrice: Decimal
    var stock: Int
    var createdAt: Date
    var issuedAt: Date
    var images: [Image]?
    var vendors: Vendors?

    enum CodingKeys: String, CodingKey {
        case identification = "id"
        case vendorIdentification = "vendor_id"
        case name
        case description
        case thumbnail
        case currency
        case price
        case bargainPrice = "bargain_price"
        case discountedPrice = "discounted_price"
        case stock
        case createdAt = "created_at"
        case issuedAt = "issued_at"
        case images
        case vendors
    }
}

enum Currency: String, Encodable, Decodable, Hashable, CaseIterable {
    case krw = "KRW"
    case usd = "USD"
}

struct Image: Decodable, Hashable {
    var identification: Int
    var url: String
    var thumbnailUrl: String
    var isSuccess: Bool
    var issuedAt: Date

    enum CodingKeys: String, CodingKey {
        case identification = "id"
        case url
        case thumbnailUrl = "thumbnail_url"
        case isSuccess = "succeed"
        case issuedAt = "issued_at"
    }
}

struct Vendors: Decodable, Hashable {
    var name: String
    var identification: Int
    var createdAt: Date
    var issuedAt: Date

    enum CodingKeys: String, CodingKey {
        case name
        case identification = "id"
        case createdAt = "created_at"
        case issuedAt = "issued_at"
    }
}
