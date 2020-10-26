//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import Contacts
import ContactsUI

//enum Result<T, ErrorType> {
//  case success(T)
//  case error(ErrorType)
//}

protocol ContactStoreAdaptee {
  var authorizationStatus: ContactStoreAuthorizationStatus { get }
  var supportsContactEditing: Bool { get }
  func requestAccess(completionHandler: @escaping (Bool, Error?) -> Void)
  func fetchContacts() -> Result<[WalletContact], Error>
  func fetchCNContact(contactId: String) -> CNContact?
  func startObservingChanges(changeHandler: @escaping () -> Void)
}

public
class ContactsFrameworkContactStoreAdaptee: NSObject, ContactStoreAdaptee {
  private let contactStoreForLargeRequests = CNContactStore()
  private let contactStoreForSmallRequests = CNContactStore()
  private var changeHandler: (() -> Void)?
  private var initializedObserver = false
  private var lastSortOrder: CNContactSortOrder?
  
  let supportsContactEditing = true
  
  public static let allowedContactKeys: [CNKeyDescriptor] = [
    CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
    CNContactThumbnailImageDataKey as CNKeyDescriptor, // TODO full image instead of thumbnail?
    CNContactPhoneNumbersKey as CNKeyDescriptor,
    CNContactEmailAddressesKey as CNKeyDescriptor,
    CNContactPostalAddressesKey as CNKeyDescriptor,
    CNContactViewController.descriptorForRequiredKeys(),
    CNContactVCardSerialization.descriptorForRequiredKeys()
  ]
  
  var authorizationStatus: ContactStoreAuthorizationStatus {
    let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
    switch authorizationStatus {
    case .notDetermined:
      return .notDetermined
    case .restricted:
      return .restricted
    case .denied:
      return .denied
    case .authorized:
      return .authorized
    @unknown default:
      assertionFailure("unexpected value: \(authorizationStatus.rawValue)")
      return .authorized
    }
  }
  
  func startObservingChanges(changeHandler: @escaping () -> Void) {
    // should only call once
    assert(self.changeHandler == nil)
    self.changeHandler = changeHandler
    self.lastSortOrder = CNContactsUserDefaults.shared().sortOrder
    NotificationCenter.default.addObserver(self, selector: #selector(runChangeHandler), name: .CNContactStoreDidChange, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
  }
  
  @objc
  func didBecomeActive() {
      let currentSortOrder = CNContactsUserDefaults.shared().sortOrder
      
      guard currentSortOrder != self.lastSortOrder else {
        // sort order unchanged
        return
      }
      
      Logger.info("sort order changed: \(String(describing: self.lastSortOrder)) -> \(String(describing: currentSortOrder))")
      self.lastSortOrder = currentSortOrder
      self.runChangeHandler()
  }
  
  @objc
  func runChangeHandler() {
    guard let changeHandler = self.changeHandler else {
      assertionFailure("trying to run change handler before it was registered")
      return
    }
    changeHandler()
  }
  
  func requestAccess(completionHandler: @escaping (Bool, Error?) -> Void) {
    contactStoreForLargeRequests.requestAccess(for: .contacts, completionHandler: completionHandler)
  }
  
  func fetchContacts() -> Result<[WalletContact], Error> {
    var systemContacts = [CNContact]()
    do {
      let contactFetchRequest = CNContactFetchRequest(keysToFetch: ContactsFrameworkContactStoreAdaptee.allowedContactKeys)
      contactFetchRequest.sortOrder = .userDefault
      try contactStoreForLargeRequests.enumerateContacts(with: contactFetchRequest) { (contact, _) -> Void in
        systemContacts.append(contact)
      }
    } catch let error as NSError {
      if error.domain == CNErrorDomain, error.code == CNError.Code.communicationError.rawValue {
        // this seems occur intermittently, but not uncommonly.
        Logger.warning("communication error: \(error)")
      } else {
        assertionFailure("Failed to fetch contacts with error:\(error)")
      }
      return .failure(error)
    }
    
    let contacts = systemContacts.map { WalletContact(systemContact: $0) }
    return .success(contacts)
  }
  
  func fetchCNContact(contactId: String) -> CNContact? {
    var result: CNContact?
    do {
      let contactFetchRequest = CNContactFetchRequest(keysToFetch: ContactsFrameworkContactStoreAdaptee.allowedContactKeys)
      contactFetchRequest.sortOrder = .userDefault
      contactFetchRequest.predicate = CNContact.predicateForContacts(withIdentifiers: [contactId])
      
      try self.contactStoreForSmallRequests.enumerateContacts(with: contactFetchRequest) { (contact, _) -> Void in
        guard result == nil else {
          assertionFailure("More than one contact with contact id.")
          return
        }
        result = contact
      }
    } catch let error as NSError {
      if error.domain == CNErrorDomain && error.code == CNError.communicationError.rawValue {
        // These errors are transient and can be safely ignored.
        Logger.error("Communication error: \(error)")
        return nil
      }
      assertionFailure("Failed to fetch contact with error:\(error)")
      return nil
    }
    
    return result
  }
}

public enum ContactStoreAuthorizationStatus: UInt {
  case notDetermined,
       restricted,
       denied,
       authorized
}

public protocol SystemContactsFetcherDelegate: class {
  func systemContactsFetcher(_ systemContactsFetcher: SystemContactsFetcher, updatedContacts contacts: [WalletContact], isUserRequested: Bool)
  func systemContactsFetcher(_ systemContactsFetcher: SystemContactsFetcher, hasAuthorizationStatus authorizationStatus: ContactStoreAuthorizationStatus)
}

public class SystemContactsFetcher: NSObject {
  
  private let serialQueue = DispatchQueue(label: "SystemContactsFetcherQueue")
  
  var lastContactUpdateHash: Int?
  var lastDelegateNotificationDate: Date?
  let contactStoreAdapter: ContactsFrameworkContactStoreAdaptee
  
  public weak var delegate: SystemContactsFetcherDelegate?
  
  public var authorizationStatus: ContactStoreAuthorizationStatus {
    return contactStoreAdapter.authorizationStatus
  }
  
  public var isAuthorized: Bool {
    guard self.authorizationStatus != .notDetermined else {
      assertionFailure("should have called `requestOnce` before checking authorization status.")
      return false
    }
    
    return self.authorizationStatus == .authorized
  }
  
  public var isDenied: Bool {
    return self.authorizationStatus == .denied
  }
  
  public private(set) var systemContactsHaveBeenRequestedAtLeastOnce = false
  private var hasSetupObservation = false
  
  override init() {
    self.contactStoreAdapter = ContactsFrameworkContactStoreAdaptee()
    
    super.init()
    
  }
  
  public var supportsContactEditing: Bool {
    return self.contactStoreAdapter.supportsContactEditing
  }
  
  private func setupObservationIfNecessary() {
    guard !hasSetupObservation else {
      return
    }
    hasSetupObservation = true
    self.contactStoreAdapter.startObservingChanges { [weak self] in
      DispatchQueue.main.async {
        self?.refreshAfterContactsChange()
      }
    }
  }
  
  /**
   * Ensures we've requested access for system contacts. This can be used in multiple places,
   * where we might need contact access, but will ensure we don't wastefully reload contacts
   * if we have already fetched contacts.
   *
   * @param   completionParam  completion handler is called on main thread.
   */
  public func requestOnce(completion completionParam: ((Error?) -> Void)?) {
    
    // Ensure completion is invoked on main thread.
    let completion = { error in
      DispatchQueue.main.async {
        completionParam?(error)
      }
    }
    
//    guard !systemContactsHaveBeenRequestedAtLeastOnce else {
//      completion(nil)
//      return
//    }
    setupObservationIfNecessary()
    
    switch authorizationStatus {
    case .notDetermined:
      self.contactStoreAdapter.requestAccess { (granted, error) in
        if let error = error {
          Logger.error("error fetching contacts: \(error)")
          completion(error)
          return
        }
        
        guard granted else {
          // This case should have been caught by the error guard a few lines up.
          assertionFailure("declined contact access.")
          completion(nil)
          return
        }
        
        DispatchQueue.main.async {
          self.updateContacts(completion: completion)
        }
      }
    case .authorized:
      self.updateContacts(completion: completion)
    case .denied, .restricted:
      Logger.debug("contacts were \(self.authorizationStatus)")
      self.delegate?.systemContactsFetcher(self, hasAuthorizationStatus: authorizationStatus)
      completion(nil)
    }
  }
  
  public func fetchOnceIfAlreadyAuthorized() {
    guard authorizationStatus == .authorized else {
      self.delegate?.systemContactsFetcher(self, hasAuthorizationStatus: authorizationStatus)
      return
    }
//    guard !systemContactsHaveBeenRequestedAtLeastOnce else {
//      return
//    }
    
    updateContacts(completion: nil, isUserRequested: false)
  }
  
  public func userRequestedRefresh(completion: @escaping (Error?) -> Void) {
    
    guard authorizationStatus == .authorized else {
      assertionFailure("should have already requested contact access")
      self.delegate?.systemContactsFetcher(self, hasAuthorizationStatus: authorizationStatus)
      completion(nil)
      return
    }
    
    updateContacts(completion: completion, isUserRequested: true)
  }
  
  public func refreshAfterContactsChange() {
    guard authorizationStatus == .authorized else {
      Logger.info("ignoring contacts change; no access.")
      self.delegate?.systemContactsFetcher(self, hasAuthorizationStatus: authorizationStatus)
      return
    }
    
    updateContacts(completion: nil, isUserRequested: false)
  }
  
  private func updateContacts(completion completionParam: ((Error?) -> Void)?, isUserRequested: Bool = false) {
    // Ensure completion is invoked on main thread.
    let completion: (Error?) -> Void = { error in
      DispatchQueue.main.async {
        completionParam?(error)
      }
    }
    
    systemContactsHaveBeenRequestedAtLeastOnce = true
    setupObservationIfNecessary()
    
    serialQueue.async {
      
      Logger.info("fetching contacts")
      
      var fetchedContacts: [WalletContact]?
      switch self.contactStoreAdapter.fetchContacts() {
      case .success(let result):
        fetchedContacts = result
      case .failure(let error):
        completion(error)
        return
      }
      
      guard let contacts = fetchedContacts else {
        assertionFailure("contacts was unexpectedly not set.")
        completion(nil)
        return
      }
      
      Logger.info("fetched \(contacts.count) contacts.")
      
      let contactsHash = contacts.hashValue
      
      DispatchQueue.main.async {
        var shouldNotifyDelegate = false
        
        if self.lastContactUpdateHash != contactsHash {
          Logger.info("contact hash changed. new contactsHash: \(contactsHash)")
          shouldNotifyDelegate = true
        } else if isUserRequested {
          Logger.info("ignoring debounce due to user request")
          shouldNotifyDelegate = true
        } else {
          
          // If nothing has changed, only notify delegate (to perform contact intersection) every N hours
          if let lastDelegateNotificationDate = self.lastDelegateNotificationDate {
            let kDebounceInterval = TimeInterval(12 * 60 * 60)
            
            let expiresAtDate = Date(timeInterval: kDebounceInterval, since: lastDelegateNotificationDate)
            if  Date() > expiresAtDate {
              Logger.info("debounce interval expired at: \(expiresAtDate)")
              shouldNotifyDelegate = true
            } else {
              Logger.info("ignoring since debounce interval hasn't expired")
            }
          } else {
            Logger.info("first contact fetch. contactsHash: \(contactsHash)")
            shouldNotifyDelegate = true
          }
        }
        
        guard shouldNotifyDelegate else {
          Logger.info("no reason to notify delegate.")
          
          completion(nil)
          
          return
        }
        
        self.lastDelegateNotificationDate = Date()
        self.lastContactUpdateHash = contactsHash
        
        self.delegate?.systemContactsFetcher(self, updatedContacts: contacts, isUserRequested: isUserRequested)
        completion(nil)
      }
    }
  }
  
  public func fetchCNContact(contactId: String) -> CNContact? {
    guard authorizationStatus == .authorized else {
      Logger.error("contact fetch failed; no access.")
      return nil
    }
    
    return contactStoreAdapter.fetchCNContact(contactId: contactId)
  }
}
