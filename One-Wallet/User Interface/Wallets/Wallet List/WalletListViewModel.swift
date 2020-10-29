//
//  WalletListViewModel.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 12/03/1442 AH.
//

import Foundation
import Combine
import GRDB

class WalletListViewModel {
  
  init() {
    self.setupObserving()
  }
  
  //MARK:- Private Published Objects
  @Published private var _wallets: [Wallet] = []
  
  //MARK:- Published Objects as Publishers
  var wallets: AnyPublisher<[Wallet], Never> {
    return $_wallets.eraseToAnyPublisher()
  }
  
  //MARK:- Private iVars
  private var tokens: Set<AnyCancellable> = Set<AnyCancellable>()
  
  private func setupObserving() {
    let observation = ValueObservation.tracking { database in
      try Wallet.fetchAll(database)
    }
    observation
      .publisher(in: GRDBManager.shared.grdbStorage.pool)
      .replaceError(with: [])
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { users in
        self._wallets = users
      })
      .store(in: &tokens)
  }
}
