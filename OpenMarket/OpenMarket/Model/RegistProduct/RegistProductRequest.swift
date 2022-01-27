//
//  RegistProductRequest.swift
//  OpenMarket
//
//  Created by 서녕 on 2022/01/10.
//

import Foundation

struct RegistProductRequest: Codable {
    let vendorID: String
    let productParam: ProductParam
    let images: [Image]
    
    private enum CodingKeys: String, CodingKey {
        case vendorID = "identifier"
        case productParam = "params"
        case images
    }
}
