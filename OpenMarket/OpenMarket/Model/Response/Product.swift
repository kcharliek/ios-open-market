//
//  Product.swift
//  OpenMarket
//
//  Created by Ari on 2022/01/03.
//

import Foundation

struct Product: Codable {
    let id: Int
    let vendorID: Int
    let name: String
    var thumbnail: String
    var currency: Currency
    var price: Int
    var bargainPrice: Int
    var discountedPrice: Int
    var stock: Int
    var createdAt: String
    var issuedAt: String
    var images: [Image]?
    var vendors: Vendors?
    
    enum CodingKeys: String, CodingKey {
        case id, stock, name, thumbnail, currency, price, images, vendors
        case vendorID = "vendor_id"
        case bargainPrice = "bargain_price"
        case discountedPrice = "discounted_price"
        case createdAt = "created_at"
        case issuedAt = "issued_at"
    }
}