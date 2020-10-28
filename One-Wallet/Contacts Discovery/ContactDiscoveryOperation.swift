//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import Combine

struct DiscoveredContactInfo: Hashable {
  let e164: String?
  let uuid: UUID?         // This should be made non-optional when we drop Legacy CDS
}

/// An item that fetches contact info from the ContactDiscoveryService
/// Intended to be used by ContactDiscoveryTask. You probably don't want to use this directly.
protocol ContactDiscovering {
  /// Constructs a ContactDiscovering object from a set of e164 phone numbers
  init(e164sToLookup: Set<String>)
  
  /// Returns a promise that performs ContactDiscovery on the provided queue
  func perform(on queue: DispatchQueue) -> AnyPublisher<Set<DiscoveredContactInfo>, Never>
}

class ContactDiscoveryOperation: ContactDiscovering {
  
  private let e164sToLookup: Set<String>
  required init(e164sToLookup: Set<String>) {
    self.e164sToLookup = e164sToLookup
    Logger.debug("with e164sToLookup.count: \(e164sToLookup.count)")
  }
  
  func perform(on queue: DispatchQueue) -> AnyPublisher<Set<DiscoveredContactInfo>, Never> {
    let e164sByHash = mapHashToE164()
    let allHashes = Set<String>(e164sByHash.keys)
    let request = ContactIntersectionRequest(contacts: allHashes)
    
    return repo.intersectContacts(with: request)
      .map { response in
        let discoveredNumbers = self.parse(response: response, e164sByHash: e164sByHash)
        return Set(discoveredNumbers.map { DiscoveredContactInfo(e164: $0, uuid: nil) })
      }
      .replaceError(with: Set<DiscoveredContactInfo>())
      .receive(on: queue)
      .eraseToAnyPublisher()
  }
  
  // MARK: - Private
  
  private func mapHashToE164() -> [String: String] {
    var e164sByHash: [String: String] = [:]
    
    for e164 in e164sToLookup {
      guard let hash = Cryptography.truncatedSHA1Base64EncodedWithoutPadding(e164) else {
        assertionFailure("could not hash recipient id: \(e164)")
        continue
      }
      assert(e164sByHash[hash] == nil)
      e164sByHash[hash] = e164
    }
    return e164sByHash
  }
    
  private func parse(response: ContactIntersectionResponse, e164sByHash: [String: String]) -> Set<String> {
    var registeredRecipientIds: Set<String> = Set()
    
    for intersection in response.contacts {
      guard intersection.token.count > 0 else {
        assertionFailure("hash was unexpectedly nil")
        continue
      }
      
      guard let e164 = e164sByHash[intersection.token], e164.count > 0 else {
        assertionFailure("phoneNumber was unexpectedly nil")
        continue
      }
      
      guard e164sToLookup.contains(e164) else {
        assertionFailure("unexpected phoneNumber")
        continue
      }
      
      registeredRecipientIds.insert(e164)
    }
    
    return registeredRecipientIds
  }
}

// MARK: - Dependencies

extension ContactDiscoveryOperation {
  private var repo: ContactsRepo {
    return containersProvider.repositoryProvider.contactsRepo
  }
}
