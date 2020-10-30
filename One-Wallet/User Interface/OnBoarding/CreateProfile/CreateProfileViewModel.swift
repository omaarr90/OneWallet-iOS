//
//  CreateProfileViewModel.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 13/03/1442 AH.
//

import UIKit
import Combine

class CreateProfileViewModel {

  init() {
    tryToFetchUserProfile()
  }
  
  //MARK:- Private Published Objects
  @Published private var _response: WalletUser? = nil
  
  //MARK:- Published Objects as Publishers
  var response: AnyPublisher<WalletUser?, Never> {
    return $_response.eraseToAnyPublisher()
  }
  
  //MARK:- Private iVars
  private var tokens: Set<AnyCancellable> = Set<AnyCancellable>()
  
  func tryToFetchUserProfile() {
    _response = WalletUser.fetchLocalUser()
  }
}
