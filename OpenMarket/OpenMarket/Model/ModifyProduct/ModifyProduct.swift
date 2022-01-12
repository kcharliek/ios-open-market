//
//  modifyProduct.swift
//  OpenMarket
//
//  Created by 서녕 on 2022/01/09.
//

import Foundation

struct ModifyProduct: Codable {
    let vendorID: String
    let productNumber: Int
    let name: String
    let descripstions: String
    let thumbnailID: Int
    let price: Int
    let currency: Currency
    let discountedPrice: Int
    let stock: Int
    let secret: String
    
    private enum CodingKeys: String, CodingKey {
        case vendorID
        case productNumber = "product_id"
        case name
        case descripstions
        case thumbnailID = "thumbnail_id"
        case price
        case currency
        case discountedPrice = "discounted_price"
        case stock
        case secret
    }
}
