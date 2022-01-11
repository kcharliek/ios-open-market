//
//  APIServicable.swift
//  OpenMarket
//
//  Created by Jun Bang on 2022/01/04.
//

import Foundation

protocol APIServicable: JSONParsable {
    func registerProduct(product: PostProduct, images: [Data], completionHandler: @escaping (Result<Data, APIError>) -> Void)
    func updateProduct(productID: Int, product: PatchProduct)
    func getSecret(productID: Int, secret: String)
    func deleteProduct(productID: Int, productSecret: String)
    func fetchProduct(productID: Int, completionHandler: @escaping (Result<Product, APIError>) -> Void)
    func fetchPage(pageNumber: Int, itemsPerPage: Int, completionHandler: @escaping (Result<Page, APIError>) -> Void) 
}

