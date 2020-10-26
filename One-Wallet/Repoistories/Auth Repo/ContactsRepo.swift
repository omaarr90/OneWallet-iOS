//
//  ContactsRepo.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 08/03/1442 AH.
//

import Foundation
import Combine


public struct ContactIntersectionRequest: NetworkModel {
  let contacts: Set<String>
}

public struct ContactIntersectionResponse: NetworkModel {
  let contacts: [ContactIntersection]
}

public struct ContactIntersection: NetworkModel {
  let token: String
}


public protocol ContactsRepo {
  func intersectContacts(with model: ContactIntersectionRequest) -> AnyPublisher<ContactIntersectionResponse, Error>
}

public class MockContactsRepo: ContactsRepo {
  public func intersectContacts(with model: ContactIntersectionRequest) -> AnyPublisher<ContactIntersectionResponse, Error> {
    let subset = model.contacts.prefix(10)
    let intersection = subset.map { ContactIntersection.init(token: $0)}
    let response = ContactIntersectionResponse.init(contacts: intersection)
    return Future { resolve in
      resolve(.success(response))
    }
    .eraseToAnyPublisher()
  }
}

public class WalletContactsRepo: ContactsRepo {
  public func intersectContacts(with model: ContactIntersectionRequest) -> AnyPublisher<ContactIntersectionResponse, Error> {
    fatalError("not implemented")
  }
}
