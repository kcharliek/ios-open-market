//
//  HTTPUtility.swift
//  OpenMarket
//
//  Created by yeha on 2022/01/06.
//

import Foundation

enum HTTPUtility {
    static let baseURL: String = "https://market-training.yagom-academy.kr/"
    static let productPath: String = "api/products/"
    static let defaultHeader: [String: String] = [
        "identifier": UserDefaultUtility().getVendorIdentification()
    ]
    static let defaultSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration)
    }()
    static func urlRequest(urlString: String, method: HttpMethod = .get) -> URLRequest? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return request
    }

    enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }
}

extension URLRequest {
    mutating func addHTTPHeaders(headers: [String: String]) {
        headers.forEach { (key, value) in
            self.addValue(value, forHTTPHeaderField: key)
        }
    }
}
