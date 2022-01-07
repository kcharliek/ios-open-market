import Foundation

struct NetworkTask {
    private let boundary = UUID().uuidString
    let jsonParser: JSONParsable
    
    func requestHealthChekcer(completionHandler: @escaping (Result<Data, Error>) -> Void) {
        guard let url = NetworkAddress.healthChecker.url else { return }
        let request = request(url: url, httpMethod: "GET")
        let task = dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    func requestProductRegistration(
        identifier: String,
        salesInformation: SalesInformation,
        images: [String: Data],
        completionHandler: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let url = NetworkAddress.productRegistration.url else { return }
        let body = buildBody(with: salesInformation, images: images)
        let request = request(
            url: url,
            httpMethod: "POST",
            httpHeaders: [
                "identifier": identifier,
                "Content-Type": "multipart/form-data; boundary=\(boundary)"
            ],
            httpBody: body
        )
        let task = dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    func requestProductModification(
        identifier: String,
        productId: Int,
        information: ModificationInformation,
        completionHandler: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let url = NetworkAddress.productModification(productId: productId).url else {
            return
        }
        let body = try? jsonParser.encode(from: information)
        let request = request(
            url: url,
            httpMethod: "PATCH",
            httpHeaders: ["identifier": identifier],
            httpBody: body
        )
        let task = dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    func requestProductSecret(
        productId: Int,
        identifier: String,
        secret: String,
        completionHandler: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let url = NetworkAddress.secret(productId: productId).url else { return }
        let body = try? jsonParser.encode(from: secret)
        let request = request(
            url: url,
            httpMethod: "POST",
            httpHeaders: ["identifier": identifier],
            httpBody: body
        )
        let task = dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    func requestRemoveProduct(
        identifier: String,
        productId: Int,
        productSecret: String,
        completionHandler: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let url = NetworkAddress.removeProduct(
            productId: productId,
            productSecret: productSecret).url else { return }
        let body = try? jsonParser.encode(from: productSecret)
        let request = request(
            url: url,
            httpMethod: "DELETE",
            httpHeaders: ["identifier": identifier],
            httpBody: body
        )
        let task = dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    func requestProductDetail(
        productId: Int,
        completionHandler: @escaping (Result<Data, Error>) -> Void) {
            guard let url = NetworkAddress.productDetail(productId: productId).url else { return }
            let request = request(url: url, httpMethod: "GET")
            let task = dataTask(with: request, completionHandler: completionHandler)
            task.resume()
        }
    
    func requestProductList(
        pageNumber: Int,
        itemsPerPage: Int,
        completionHandler: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let url = NetworkAddress.productList(
            pageNumber: pageNumber,
            itemsPerPage: itemsPerPage).url else { return }
        let request = request(url: url, httpMethod: "GET")
        let task = dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    private func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionDataTask {
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                      completionHandler(.failure(NetworkError.httpError))
                      return
                  }
            guard let data = data else { return }
            completionHandler(.success(data))
        }
        return dataTask
    }
    
    private func request(
        url: URL,
        httpMethod: String,
        httpHeaders: [String: String] = [:],
        httpBody: Data? = nil
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        httpHeaders.forEach { httpHeaderField, value in
            request.addValue(value, forHTTPHeaderField: httpHeaderField)
        }
        request.httpBody = httpBody
        return request
    }
    
    private func buildBody(
        with salesInformation: SalesInformation,
        images: [String: Data]
    ) -> Data? {
        guard let endBoundary = "\r\n--\(boundary)--".data(using: .utf8) else {
            return nil
        }
        guard let newLine = "\r\n".data(using: .utf8) else {
            return nil
        }
        guard let salesInformation = try? jsonParser.encode(from: salesInformation) else {
            return nil
        }
        var data = Data()
        var paramsBody = ""
        paramsBody.append("--\(boundary)\r\n")
        paramsBody.append("Content-Disposition: form-data; name=\"params\"\r\n\r\n")
        guard let paramsBody = paramsBody.data(using: .utf8) else {
            return nil
        }
        data.append(paramsBody)
        data.append(salesInformation)
        images.forEach { (fileName, image) in
            var imagesBody = ""
            imagesBody.append("\r\n--\(boundary)\r\n")
            imagesBody.append(
                "Content-Disposition: form-data; name=\"images\"; filename=\(fileName)\r\n"
            )
            guard let imagesBody = imagesBody.data(using: .utf8) else { return }
            data.append(imagesBody)
            data.append(newLine)
            data.append(image)
        }
        data.append(endBoundary)
        return data
    }
}

extension NetworkTask {
    private enum NetworkAddress {
        static let apiHost = "https://market-training.yagom-academy.kr"
        
        case healthChecker
        case productRegistration
        case productModification(productId: Int)
        case productDetail(productId: Int)
        case productList(pageNumber: Int, itemsPerPage: Int)
        case secret(productId: Int)
        case removeProduct(productId: Int, productSecret: String)
        
        var url: URL? {
            switch self {
            case .healthChecker:
                let url = URL(string: Self.apiHost + "/healthChecker")
                return url
            case .productRegistration:
                let url = URL(string: Self.apiHost + "/api/products")
                return url
            case let .productModification(productId):
                let url = URL(string: Self.apiHost + "/api/products/\(productId)")
                return url
            case let .productDetail(productId):
                let url = URL(
                    string: Self.apiHost + "/api/products/" + String(productId)
                )
                return url
            case let .productList(pageNumber, itemsPerPage):
                var urlComponents = URLComponents(
                    string: Self.apiHost + "/api/products?"
                )
                let pageNumber = URLQueryItem(name: "page_no", value: String(pageNumber))
                let itemsPerPage = URLQueryItem(
                    name: "items_per_page", value: String(itemsPerPage)
                )
                urlComponents?.queryItems?.append(pageNumber)
                urlComponents?.queryItems?.append(itemsPerPage)
                return urlComponents?.url
            case let .secret(productId):
                let url = URL(
                    string: Self.apiHost + "/api/products/\(productId)/secret"
                )
                return url
            case let .removeProduct(productId, productSecret):
                let url = URL(
                    string: Self.apiHost + "/api/products/\(productId)/\(productSecret)"
                )
                return url
            }
        }
    }
    
    struct SalesInformation: Encodable {
        let name: String
        let descriptions: String
        let price: Double
        let currency: Currency
        let discountedPrice: Double?
        let stock: Int?
        let secret: String
    }
    
    struct ModificationInformation: Encodable {
        let name: String?
        let descriptions: String?
        let thumbnail_id: Int?
        let price: Int?
        let currency: Currency?
        let discountedPrice: Double?
        let stock: Int?
        let secret: String
    }
}
