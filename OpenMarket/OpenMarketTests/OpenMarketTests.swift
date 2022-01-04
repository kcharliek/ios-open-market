//
//  OpenMarketTests.swift
//  OpenMarketTests
//
//  Created by JeongTaek Han on 2022/01/03.
//

import XCTest

class OpenMarketTests: XCTestCase {
    
    var sutURLSessionProvider: URLSessionProvider!
    
    override func setUpWithError() throws {
        let data = NSDataAsset(name: "products")?.data
        guard let url = URL(string: "https://market-training.yagom-academy.kr/") else {
            return
        }
        
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let dummy = DummyData(data: data, response: response, error: nil)
        let urlSession = StubURLSession(dummy: dummy)
        
        sutURLSessionProvider = URLSessionProvider(
            session: urlSession,
            baseURL: "https://market-training.yagom-academy.kr/"
        )
        
    }

    override func tearDownWithError() throws {
        sutURLSessionProvider = nil
    }

    func testExample() throws {
        guard let url = URL(string: "https://market-training.yagom-academy.kr/") else {
            return
        }
        
        sutURLSessionProvider.request(URLRequest(url: url)) { result in
            
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                do {
                    let result = try decoder.decode(Page.self, from: data)
                    print(result)
                    XCTAssertNotNil(result)
                } catch {
                    XCTFail("error")
                }
                
            case .failure(let error):
                XCTFail("error")
            }
            
        }
    }

}
