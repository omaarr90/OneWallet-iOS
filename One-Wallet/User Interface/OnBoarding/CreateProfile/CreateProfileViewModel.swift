//
//  CreateProfileViewModel.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 13/03/1442 AH.
//

import UIKit
import Combine
import GRDB

class CreateProfileViewModel {

  init() {
    setupObserving()
  }
  
  //MARK:- Private Published Objects
  @Published private var _response: WalletUser? = nil
  
  //MARK:- Published Objects as Publishers
  var response: AnyPublisher<WalletUser?, Never> {
    return $_response.eraseToAnyPublisher()
  }
  
  //MARK:- Private iVars
  private var tokens: Set<AnyCancellable> = Set<AnyCancellable>()
  
  private func setupObserving() {
    
    guard let phoneNumber = WalletAccount.localAccount?.phoneNumber else {
      return
    }
    let observation = ValueObservation.tracking { database in
      try WalletUser.fetchOne(database, sql: "SELECT * FROM model_WalletUser WHERE phoneNumber = ?", arguments: [phoneNumber])
    }
    observation
      .publisher(in: GRDBManager.shared.grdbStorage.pool)
      .replaceError(with: nil)
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { users in
        self._response = users
      })
      .store(in: &tokens)
  }
}
