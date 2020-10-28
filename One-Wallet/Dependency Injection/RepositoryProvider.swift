//
//  RepositoryContainer.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 11/03/1442 AH.
//

import Foundation
import Swinject

protocol RepositoryProvider: InjectionContainer {
  var authRepo: AuthRepo { get }
  var contactsRepo: ContactsRepo { get }
}

final class WalletRepositoryProvider: RepositoryProvider {
  var authRepo: AuthRepo {
    container.resolve(AuthRepo.self)!
  }
  var contactsRepo: ContactsRepo {
    container.resolve(ContactsRepo.self)!
  }
  
  internal var container: Container
  init() {
    container = Container()
    container.register(AuthRepo.self) {  _ in
      WalletAuthRepo(api: containersProvider.networkingProvider.apiClient)
    }

    container.register(ContactsRepo.self) {  _ in
      WalletContactsRepo(api: containersProvider.networkingProvider.apiClient)
    }
  }
}
