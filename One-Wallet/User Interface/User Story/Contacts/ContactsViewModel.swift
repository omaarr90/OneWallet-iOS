//
//  ContactsViewModel.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 08/03/1442 AH.
//

import Foundation
import Combine

class ContactsViewModel {
  
  //MARK:- Dependencies
  private let contactsRepo: ContactsRepo
  
  init(contactsRepo: ContactsRepo) {
    self.contactsRepo = contactsRepo
    self.getAllContacts()
  }
  
  //MARK:- Private Published Objects
  @Published private var _response: [Contact]? = nil
  @Published private var _isLoading: Bool = false
  @Published private var _error: Error? = nil
  
  //MARK:- Published Objects as Publishers
  var response: AnyPublisher<[Contact]?, Never> {
    return $_response.eraseToAnyPublisher()
  }
  var isLoading: AnyPublisher<Bool, Never> {
    return $_isLoading.eraseToAnyPublisher()
  }
  var error: AnyPublisher<Error?, Never> {
    return $_error.eraseToAnyPublisher()
  }
  
  //MARK:- Private iVars
  private var tokens: Set<AnyCancellable> = Set<AnyCancellable>()

  func getAllContacts() {
    self._isLoading = true
    contactsRepo.getAllContacts()
      .sink { completion in
        self._isLoading = false
        switch completion {
        case .finished:
          break
        case .failure(let error):
          self._error = error
        }
      } receiveValue: { contacts in
        self._response = contacts
      }
      .store(in: &tokens)

  }
}
