//
//  Wallet.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 12/03/1442 AH.
//

import Foundation
import GRDB

public struct Wallet: Codable {
  public var id: Int64?
  public var name: String
  public let contributers: [WalletUser]
}

extension Wallet: Hashable {}

extension Wallet: FetchableRecord, PersistableRecord {
  public static var databaseTableName: String = "model_Wallet"
  private enum Columns {
    static let id = Column(CodingKeys.id)
    static let name = Column(CodingKeys.name)
    static let contributers = Column(CodingKeys.contributers)
  }
  
  mutating public func didInsert(with rowID: Int64, for column: String?) {
    id = rowID
  }
}
