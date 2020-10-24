//
//  Data+Convinent.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 07/03/1442 AH.
//

import Foundation

public extension Data {
  func hexadecimalString() -> String {
    return reduce("") {$0 + String(format: "%02x", $1)}
  }
}
