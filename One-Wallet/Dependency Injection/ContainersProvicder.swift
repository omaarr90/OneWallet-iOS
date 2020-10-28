//
//  ContainersProvicder.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 11/03/1442 AH.
//

import Foundation
import Swinject

protocol InjectionContainer {
  var container: Swinject.Container { get }
  init()
}

protocol ContainersProvicder: InjectionContainer {
  var repositoryProvider: RepositoryProvider { get }
  var networkingProvider: NetworkingProvider { get }
  var viewModelProvider: ViewModelProvider { get }
}


let containersProvider: ContainersProvicder = WalletContainersProvicder()

final class WalletContainersProvicder: ContainersProvicder {
  
  var viewModelProvider: ViewModelProvider {
    container.resolve(ViewModelProvider.self)!
  }
  
  var networkingProvider: NetworkingProvider {
    container.resolve(NetworkingProvider.self)!
  }
  var repositoryProvider: RepositoryProvider {
    container.resolve(RepositoryProvider.self)!
  }
  
  internal var container: Container
  init() {
    container = Container()
    container.register(NetworkingProvider.self) { _ in
      WalletNetworkingProvider()
    }
    container.register(RepositoryProvider.self) { _ in
      WalletRepositoryProvider()
    }
    container.register(ViewModelProvider.self) { _ in
      WalletViewModelProvider()
    }
  }
}
