//
//  WalletAccount.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 08/03/1442 AH.
//

import Foundation
import GRDB

public struct WalletAccount: Codable {
  public var id: Int64?
  public var registrationId: UInt32
  public let phoneNumber: String?
  public let isOnboarded: Bool
  public var isRegistered: Bool
  public var uuid: String?
}

extension WalletAccount: Hashable {}

extension WalletAccount: FetchableRecord, PersistableRecord {
  public static var databaseTableName: String = "model_WalletAccount"
  private enum Columns {
    static let id = Column(CodingKeys.id)
    static let registrationId = Column(CodingKeys.registrationId)
    static let phoneNumber = Column(CodingKeys.phoneNumber)
    static let isOnboarded = Column(CodingKeys.isOnboarded)
    static let isRegistered = Column(CodingKeys.isRegistered)
  }

  mutating public func didInsert(with rowID: Int64, for column: String?) {
    id = rowID
  }
}

public extension WalletAccount {
  
  static func createLocalAccount() -> WalletAccount {
    guard let phoneNumber = try? KeychainManager.shared.getUserID() else {
      fatalError("Cannot get user phone number")
    }
    let account = WalletAccount(id: nil, registrationId: 0, phoneNumber: phoneNumber, isOnboarded: false, isRegistered: false, uuid: nil)
    try? GRDBManager.shared.grdbStorage.pool.write { database in
      try account.insert(database)
    }
    
    return account
  }
  
  func setRegistrationId(registrationId: UInt32) {
    guard let phoneNumber = self.phoneNumber else {
      fatalError("Cannot get user phone number")
    }
    try? GRDBManager.shared.grdbStorage.pool.write { database in
      var account = try? WalletAccount.fetchOne(database, sql: "select * from \(Self.databaseTableName) where phoneNumber = ?", arguments: [phoneNumber])
      account?.registrationId = registrationId
      try? account?.update(database)
    }
  }
  
  func markAsRegistered() {
    guard let phoneNumber = self.phoneNumber else {
      fatalError("Cannot get user phone number")
    }
    try? GRDBManager.shared.grdbStorage.pool.write { database in
      var account = try? WalletAccount.fetchOne(database, sql: "select * from \(Self.databaseTableName) where phoneNumber = ?", arguments: [phoneNumber])
      account?.isRegistered = true
      try? account?.update(database)
    }
  }

  func setUUID(uuid: String) {
    guard let phoneNumber = self.phoneNumber else {
      fatalError("Cannot get user phone number")
    }
    try? GRDBManager.shared.grdbStorage.pool.write { database in
      var account = try? WalletAccount.fetchOne(database, sql: "select * from \(Self.databaseTableName) where phoneNumber = ?", arguments: [phoneNumber])
      account?.uuid = uuid
      try? account?.update(database)
    }
  }

}

public extension WalletAccount {
  
  static var localAccount: WalletAccount? {
    guard let phoneNumber = try? KeychainManager.shared.getUserID() else {
      return nil
    }
    
    return try? GRDBManager.shared.grdbStorage.pool.read { database in
      let sql = "SELECT * from \(self.databaseTableName) WHERE phoneNumber = ?"
      return try? WalletAccount.fetchOne(database, sql: sql, arguments: [phoneNumber])
    }
  }
  
  static func getOrCreateLocalAccount(phoneNumber: String) -> WalletAccount {
    var walletAccount: WalletAccount?
    try? GRDBManager.shared.grdbStorage.pool.read { database in
      let sql = "SELECT * from \(self.databaseTableName) WHERE phoneNumber = ?"
      walletAccount =  try? WalletAccount.fetchOne(database, sql: sql, arguments: [phoneNumber])
    }
    return walletAccount ?? createLocalAccount()
  }
  
  func generateServerAuthToken() -> String {
    let authKey = Cryptography.generateRandomBytes(count: 16).hexadecimalString()
    try? KeychainManager.shared.saveServerAuthKey(authKey: authKey)
    return authKey
  }
  
  func generateRegistrationId() -> UInt32 {
    let registrationId = arc4random_uniform(16380) + 1
    self.setRegistrationId(registrationId: registrationId)
    return registrationId
  }
  
  func getServerUserName() -> String? {
    if let uuidString = self.uuid {
      let uuid = UUID(uuidString: uuidString)
      return uuid?.uuidString
    } else {
      return self.phoneNumber
    }
  }
}
