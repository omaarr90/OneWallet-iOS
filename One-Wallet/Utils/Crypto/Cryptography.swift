//
//  Cryptography.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 07/03/1442 AH.
//

import Foundation
import CryptoKit

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
    guard let data = value.data(using: .utf8) else {
      assertionFailure("Couldn't create data for \(value)")
      return nil
    }
    
    let hash = Insecure.SHA1.hash(data: data)
    let truncated = hash.prefix(10)
    let truncatedData = Data(truncated)
    let base64 = truncatedData.base64EncodedString(options: .init(rawValue: 0))
     return base64.replacingOccurrences(of: "=", with: "")
  }
}
