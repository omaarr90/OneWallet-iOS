//
//  ViewModelProvider.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 11/03/1442 AH.
//

import Foundation
import Swinject

protocol ViewModelProvider: InjectionContainer {
  var signUpViewModel: SignUpViewModel { get }
  var verifyPhoneNumberViewModel: VerifyPhoneNumberViewModel { get }
  var contactsViewModel: ContactsViewModel { get }
  var walletListViewModel: WalletListViewModel { get }
}

final class WalletViewModelProvider: ViewModelProvider {
  
  var signUpViewModel: SignUpViewModel {
    container.resolve(SignUpViewModel.self)!
  }
  
  var verifyPhoneNumberViewModel: VerifyPhoneNumberViewModel {
    container.resolve(VerifyPhoneNumberViewModel.self)!
  }
  
  var contactsViewModel: ContactsViewModel {
    container.resolve(ContactsViewModel.self)!
  }
  
  var walletListViewModel: WalletListViewModel {
    container.resolve(WalletListViewModel.self)!
  }

  
  var container: Container
  
  init() {
    self.container = Container()
    
    self.container.register(SignUpViewModel.self) { _ in
      SignUpViewModel(authRepo: containersProvider.repositoryProvider.authRepo)
    }

    self.container.register(VerifyPhoneNumberViewModel.self) { _ in
      VerifyPhoneNumberViewModel(authRepo: containersProvider.repositoryProvider.authRepo)
    }
    
    self.container.register(ContactsViewModel.self) { _ in
      ContactsViewModel()
    }

    self.container.register(WalletListViewModel.self) { _ in
      WalletListViewModel()
    }

  }
  
}
