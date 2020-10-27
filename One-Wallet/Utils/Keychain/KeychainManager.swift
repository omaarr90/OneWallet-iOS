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
  private let serverAuthKey = "serverAuthKey"
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
  
  public func saveServerAuthKey(authKey: String) throws {
    try keychain.set(authKey, key: serverAuthKey)
  }
  
  public func saveUserID(userID: String) throws {
    try keychain.set(userID, key: userIDKey)
  }
  
  public func getServerAuthKey() throws -> String? {
    return try keychain.getString(serverAuthKey)
  }
  
  public func getUserID() throws -> String? {
    return try keychain.getString(userIDKey)
  }
}
