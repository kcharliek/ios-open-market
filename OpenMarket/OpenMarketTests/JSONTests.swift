//
//  JSONTests.swift
//  OpenMarket
//
//  Created by Eunsoo KIM on 2022/01/04.
//

import XCTest
@testable import OpenMarket

class JSONTests: XCTestCase {
  
  let jsonParser = JSONParser()

  func test_JSON파일이_파싱이_되는지() {
    guard let asset = NSDataAsset(name: AssetFileName.products) else {
      XCTFail()
      return
    }
  
    let result = jsonParser.decode(data: asset.data, type: ProductList.self)
    switch result {
    case .success(let data):
      XCTAssertNotNil(data)
    case .failure(_):
      XCTFail()
    }
  
  }
  
  func test_잘못된_제네릭_정보를_설정했을경우_fail을_반환하는지() {
    guard let asset = NSDataAsset(name: AssetFileName.products) else {
      XCTFail()
      return
    }
  
    let result = jsonParser.decode(data: asset.data, type: Product.self)
    switch result {
    case .success(_):
      XCTFail()
    case .failure(_):
      XCTAssertTrue(true)
    }
  }
}
