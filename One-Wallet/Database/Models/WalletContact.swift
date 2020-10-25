//
//  WalletContact.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 08/03/1442 AH.
//

import Foundation
import GRDB
import Contacts

public struct WalletContact: Codable {
  public var id: Int64?
  public var firstName: String?
  public let lastName: String?
  public let phoneNumbers: [String]
  public var cnContactId: String?
  public var isFromContactSync: Bool
  public var imageData: Data?

  init(systemContact: CNContact) {
    self.firstName = systemContact.givenName
    self.lastName = systemContact.familyName
    self.phoneNumbers = systemContact.phoneNumbers.map { $0.value.stringValue }
    self.cnContactId = systemContact.identifier
    self.isFromContactSync = true
    self.imageData = systemContact.imageData
  }
}

extension WalletContact: Hashable {}


public struct WalletUser: Codable {
  public var id: Int64?
  public var phoneNumber: String?
  public let contact: WalletContact?
}

extension WalletUser: Hashable {}

extension WalletUser: FetchableRecord, PersistableRecord {
  public static var databaseTableName: String = "model_WalletUser"
  private enum Columns {
    static let id = Column(CodingKeys.id)
    static let phoneNumber = Column(CodingKeys.phoneNumber)
    static let contact = Column(CodingKeys.contact)
  }
  
  mutating public func didInsert(with rowID: Int64, for column: String?) {
    id = rowID
  }
}

