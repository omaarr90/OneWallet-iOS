//
//  ContactsViewModel.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 08/03/1442 AH.
//

import Foundation
import Combine
import GRDB

class ContactsViewModel {
  
  //MARK:- Dependencies
  private let contactsRepo: ContactsRepo
  
  init(contactsRepo: ContactsRepo) {
    self.contactsRepo = contactsRepo
    self.setupObserving()
  }
  
  //MARK:- Private Published Objects
  @Published private var _users: [WalletUser] = []
  
  //MARK:- Published Objects as Publishers
  var users: AnyPublisher<[WalletUser], Never> {
    return $_users.eraseToAnyPublisher()
  }
  
  //MARK:- Private iVars
  private var tokens: Set<AnyCancellable> = Set<AnyCancellable>()
  
  private func setupObserving() {
    let observation = ValueObservation.tracking { database in
      try WalletUser.fetchAll(database)
    }
    observation
      .publisher(in: GRDBManager.shared.grdbStorage.pool)
      .replaceError(with: [])
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { users in
        self._users = users
      })
      .store(in: &tokens)

  }
}
