//
//  KeychainManager.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 07/03/1442 AH.
//

import Foundation
import KeychainAccess


public class KeychainManager {
  
  public static let shared = KeychainManager()
  
  private let walletService = "walletService"
  private let basicAuthKey = "basicAuthKey"
  private let registrationID = "registrationID"
  private let userIDKey = "userIDKey"
  private let didRunForFirstTime = "didRunForFirstTime"
  
  private let keychain: Keychain
  
  private init() {
    keychain = .init(service: walletService)
    let didRun = UserDefaults.standard.bool(forKey: didRunForFirstTime)
    if didRun == false {
      //delete keychain data for old login
      UserDefaults.standard.set(true, forKey: didRunForFirstTime)
      self.resetAll()
    }
  }
  
  public func resetAll() {
    try? keychain.removeAll()
  }
  
  public func saveBasicAuthCredintials(username: String, password: String) throws {
    guard let basicAuthCredentials = "\(username):\(password)".data(using: .utf8) else {
      fatalError("unable to generate basic auth credintials")
    }
    let base64AuthCredentials = basicAuthCredentials.base64EncodedString(options: .init(rawValue: 0))
    try keychain.set(base64AuthCredentials, key: basicAuthKey)
  }
  
  public func saveUserID(userID: String) throws {
    try keychain.set(userID, key: userIDKey)
  }
  
  public func saveRegistrationID(registrationId: UInt32) throws {
    try keychain.set("\(registrationId)", key: registrationID)
  }
  
  public func getBasicAuth() throws -> String? {
    return try keychain.getString(basicAuthKey)
  }
  
  public func getUserID() throws -> String? {
    return try keychain.getString(userIDKey)
  }

  public func getRegistrationID() throws -> UInt32? {
    if let registrationID = try keychain.getString(registrationID) {
      return UInt32(registrationID)
    }
    return nil
  }
}
