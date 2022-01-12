//
//  DeleteRequest.swift
//  OpenMarket
//
//  Created by 서녕 on 2022/01/09.
//

import Foundation

struct DeleteProductRequest: Codable {
    let vendorID: String
    let productNumber: Int
    let productSecretKey: String
    
    private enum CodingKeys: String, CodingKey {
        case vendorID = "identifier"
        case productNumber = "product_id"
        case productSecretKey = "product_secret"
    }
}
