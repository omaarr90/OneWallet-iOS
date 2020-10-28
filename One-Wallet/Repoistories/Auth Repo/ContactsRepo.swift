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
    let subset = model.contacts.prefix(15)
    let intersection = subset.map { ContactIntersection.init(token: $0)}
    let response = ContactIntersectionResponse.init(contacts: intersection)
    return Future { resolve in
      resolve(.success(response))
    }
    .eraseToAnyPublisher()
  }
}

private extension Request {
  static func contactsIntersection(model: ContactIntersectionRequest, completion: @escaping (Result<ContactIntersectionResponse, APIError>) -> Void) -> Request {
    Request.post(method: .put,
                 baseURL: containersProvider.networkingProvider.backendService.baseURL,
                 path: "v1/directory/tokens",
                 params: nil,
                 body: model) { result in
      result.decoding(ContactIntersectionResponse.self, completion: completion)
    }
  }
}

public class WalletContactsRepo: ContactsRepo {
  
  private var api: APIClient
  
  init(api: APIClient) {
    self.api = api
  }

  public func intersectContacts(with model: ContactIntersectionRequest) -> AnyPublisher<ContactIntersectionResponse, Error> {
    return Future { resolve in
      self.api.send(request: .contactsIntersection(model: model, completion: { result in
        switch result {
        case .success(let response):
          resolve(.success(response))
        case .failure(let error):
          resolve(.failure(error))
        }
      }))

    }
    .eraseToAnyPublisher()
  }
}
