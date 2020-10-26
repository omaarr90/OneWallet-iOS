//
//  Cryptography.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 07/03/1442 AH.
//

import Foundation

public struct Cryptography {
  
  public static func generateRandomBytes(count: Int) -> Data {
    var bytes = [Int8](repeating: 0, count: 16)
    let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
    
    if status == errSecSuccess { // Always test the status.
      return Data(bytes: bytes, count: count)
    }
    fatalError("Could not generate random bytes")
  }
  
  public static func truncatedSHA1Base64EncodedWithoutPadding(_ value: String) -> String? {
    return value
  }
}
