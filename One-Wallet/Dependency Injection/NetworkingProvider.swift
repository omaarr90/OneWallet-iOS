//
//  NetworkingProvider.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 11/03/1442 AH.
//

import Foundation
import Swinject

protocol NetworkingProvider: InjectionContainer {
  var backendService: BackendService { get }
  var apiClient: APIClient { get }
}

final class WalletNetworkingProvider: NetworkingProvider {
  var backendService: BackendService {
    container.resolve(BackendService.self)!
  }
  
  var apiClient: APIClient {
    container.resolve(APIClient.self)!
  }
  
  internal var container: Container
  init() {
    container = Container()
    container.register(BackendService.self) { _ in
      TextSecureService()
    }
    container.register(APIClient.self) { [unowned self] _ in
      self.backendService.api
    }
  }
}
