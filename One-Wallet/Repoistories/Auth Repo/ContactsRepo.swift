//
//  ContactsRepo.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 08/03/1442 AH.
//

import Foundation
import Combine

public struct Contact: Hashable {
  let phoneNumber: String
  let name: String
}

public protocol ContactsRepo {
  func getAllContacts() -> AnyPublisher<[Contact], Error>
}

public class MockContactsRepo: ContactsRepo {
  public func getAllContacts() -> AnyPublisher<[Contact], Error> {
    return Future { resolve in
      let contacts = [Contact(phoneNumber: "+966542652273", name: "Omar"), Contact(phoneNumber: "+966542652274", name: "Bander")]
      resolve(.success(contacts))
    }.eraseToAnyPublisher()
  }
}

public class WalletContactsRepo: ContactsRepo {
  public func getAllContacts() -> AnyPublisher<[Contact], Error> {
    fatalError("not implemented")
  }
  
  
}
