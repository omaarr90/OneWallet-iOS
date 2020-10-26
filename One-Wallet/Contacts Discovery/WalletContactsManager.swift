//
//  WalletContactsManager.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 08/03/1442 AH.
//

import Foundation
import PhoneNumberKit
import Combine

private extension WalletContact {
  func e164Numbers(with phoneNumberKit: PhoneNumberKit) -> [String] {
    let allNumbers = phoneNumberKit.parse(phoneNumbers)
    return allNumbers.map { phoneNumberKit.format($0, toType: .e164) }
  }
}

public class WalletContactsManager {
  public static let shared = WalletContactsManager()
  private let collectionName = "WalletContactsManagerCollection"
  
  private let systemContactsFetcher: SystemContactsFetcher
  
  private var tokens = Set<AnyCancellable>()
  
  private lazy var phoneNumberKit: PhoneNumberKit = {
    return PhoneNumberKit()
  }()
  
  private lazy var intersectionQueue: DispatchQueue = {
    return DispatchQueue.init(label: "WalletContactsManager_IntersectionQueue", qos: .utility)
  }()

  private init() {
    self.systemContactsFetcher = SystemContactsFetcher()
    self.systemContactsFetcher.delegate = self
  }
  
  private func phoneNumbersForIntersection(with contacts: [WalletContact]) -> Set<String> {
    let allNumbers = contacts.flatMap { $0.e164Numbers(with: self.phoneNumberKit) }
    return Set(allNumbers)
  }
}

// MARK:- Contact Intersection
private extension WalletContactsManager {
  func update(with contacts: [WalletContact]) {
    let phoneNumbers = self.phoneNumbersForIntersection(with: contacts)
    let operation = ContactDiscoveryOperation(e164sToLookup: phoneNumbers)
    operation.perform(on: intersectionQueue)
      .sink { discoverdContacts in
        self.storeDiscoveredContacts(discoverdContacts, allContacts: contacts)
      }
      .store(in: &tokens)
  }
  
  func storeDiscoveredContacts(_ discoveredContacts: Set<DiscoveredContactInfo>, allContacts: [WalletContact]) {
    let _ = try? GRDBManager.shared.grdbStorage.pool.write({ database in
      try? WalletUser.deleteAll(database)
    })
    for info in discoveredContacts {
      guard let e164 = info.e164 else { continue }
      let contact = allContacts.first { $0.phoneNumbers.contains(e164) }
      let walletUser = WalletUser(id: nil, phoneNumber: e164, contact: contact)
      try? GRDBManager.shared.grdbStorage.pool.write { database in
        try? walletUser.save(database)
      }
    }
  }
}

// MARK:- System Contacts Fetching
public extension WalletContactsManager {
  
  var isAuthorized: Bool {
    return systemContactsFetcher.isAuthorized
  }
  
  var isDenied: Bool {
    return systemContactsFetcher.isDenied
  }
  
  func requestSystemContactOne() {
    self.requestSystemContactOne(with: nil)
  }
  
  func requestSystemContactOne(with completion: ((Error?) -> Void)?) {
    self.systemContactsFetcher.contactStoreAdapter.requestAccess { granted, error in
      if let error = error {
        completion?(error)
      } else if granted {
        self.systemContactsFetcher.requestOnce(completion: completion)
      }
    }
  }
  
  func fetchSystemContactsOnceIfAlreadyAuthorized() {
    self.systemContactsFetcher.contactStoreAdapter.requestAccess { granted, error in
      if granted {
        self.systemContactsFetcher.fetchOnceIfAlreadyAuthorized()
      }
    }
  }
}

extension WalletContactsManager: SystemContactsFetcherDelegate {
  public func systemContactsFetcher(_ systemContactsFetcher: SystemContactsFetcher, updatedContacts contacts: [WalletContact], isUserRequested: Bool) {
    self.update(with: contacts)
  }
  
  public func systemContactsFetcher(_ systemContactsFetcher: SystemContactsFetcher, hasAuthorizationStatus authorizationStatus: ContactStoreAuthorizationStatus) {
    //
  }
  
  
}
