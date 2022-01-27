import Foundation

class APIManager: APIManageable {
    let successRange = 200..<300
    
    func createRequest(_ url: URL, _ httpMethod: HTTPMethod) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.description

        return request
    }
    
    func requestHealthChecker(completionHandler: @escaping (Result<Data, URLSessionError>) -> Void) {
        guard let url = URLManager.healthChecker.url else {
            completionHandler(.failure(.urlIsNil))
            return
        }
        
        let request = createRequest(url, .get)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completionHandler(.failure(.requestFail))
                return
            }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode,
               !self.successRange.contains(statusCode) {
                completionHandler(.failure(.statusCodeError(statusCode)))
            }
            
            guard let data = data else {
                completionHandler(.failure(.invalidData))
                return
            }
            
            completionHandler(.success(data))
        }
        task.resume()
    }
    
    func requestProductInformation(productID: Int, completionHandler: @escaping (Result<ProductInformation, Error>) -> Void) {
        guard let url = URLManager.productInformation(productID).url else {
            completionHandler(.failure(URLSessionError.urlIsNil))
            return
        }
        
        let request = createRequest(url, .get)
        performDataTask(with: request, completionHandler)
    }
    
    func requestProductList(pageNumber: Int, itemsPerPage: Int, completionHandler: @escaping (Result<ProductList, Error>) -> Void) {
        guard let url = URLManager.productList(pageNumber, itemsPerPage).url else {
            completionHandler(.failure(URLSessionError.urlIsNil))
            return
        }
        
        let request = createRequest(url, .get)
        performDataTask(with: request, completionHandler)
    }
}

extension APIManager {
    @discardableResult
    func performDataTask<Element: Decodable>(with request: URLRequest, _ completionHandler: @escaping (Result<Element, Error>) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completionHandler(.failure(URLSessionError.requestFail))
                return
            }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode,
               !self.successRange.contains(statusCode) {
                completionHandler(.failure(URLSessionError.statusCodeError(statusCode)))
            }
            
            guard let data = data else {
                completionHandler(.failure(URLSessionError.invalidData))
                return
            }
            
            guard let parsedData = Parser<Element>.decode(from: data) else {
                completionHandler(.failure(ParserError.decodeFail))
                return
            }
            completionHandler(.success(parsedData))
        }
        task.resume()
        
        return task
    }
}
