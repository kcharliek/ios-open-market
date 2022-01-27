//
//  Data+Extension.swift
//  OpenMarket
//
//  Created by 박병호 on 2022/01/18.
//

import Foundation

extension Data {
  mutating func appendString(_ string: String) {
    guard let data = string.data(using: .utf8) else {
      return
    }
    self.append(data)
  }
}
