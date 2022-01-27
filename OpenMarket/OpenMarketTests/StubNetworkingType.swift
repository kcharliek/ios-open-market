import Foundation

@testable import OpenMarket

class StubURLSession: URLSessionProtocol {
    
    let alwaysSuccess: Bool
    var dummyData: Data?
    
    init(alwaysSuccess: Bool, dummyData: Data?) {
        self.alwaysSuccess = alwaysSuccess
        self.dummyData = dummyData
    }
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        //Nothing
        return StubURLSessionDataTask()
    }
    
    func dataTask(with urlRequest: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) -> URLSessionDataTask {
        
        guard let url = urlRequest.url else {
            return StubURLSessionDataTask()
        }
        
        let sucessResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let failureResponse = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)
        let sessionDataTask = StubURLSessionDataTask()

        if alwaysSuccess {
            sessionDataTask.resumeDidCall = {
                completionHandler(self.dummyData, sucessResponse, nil)
            }
        } else {
            sessionDataTask.resumeDidCall = {
                completionHandler(nil, failureResponse, nil)
            }
        }
        
        return sessionDataTask
    }
}

class StubURLSessionDataTask: URLSessionDataTask {
    var resumeDidCall: () -> Void = {}

    override func resume() {
        resumeDidCall()
    }
}

