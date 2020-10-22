//
//  AuthRepo.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 25/02/1442 AH.
//

import Foundation
import Combine

public struct SignupRequest: NetworkModel {
  let phoneNumber: String
  let transport: String
}

public struct SignupResponse: NetworkModel {
  let id: UUID
  let phoneNumber: String
  let verifiedByPhoneNumber: Bool
}

private extension Request {
  static func signup(model: SignupRequest, completion: @escaping (Result<SignupResponse, APIError>) -> Void) -> Request {
    Request.basic(baseURL: WalletService.baseURL, path: "v1/accounts/\(model.transport)/code/\(model.phoneNumber)") { result in
      result.decoding(SignupResponse.self, completion: completion)
    }
  }
}

public protocol AuthRepo {
  func signup(with model: SignupRequest) -> AnyPublisher<SignupResponse, Error>
}

public class MockAuthRepo: AuthRepo {
  public func signup(with model: SignupRequest) -> AnyPublisher<SignupResponse, Error> {
    return Future { resolve in
      let response = SignupResponse(id: UUID(), phoneNumber: model.phoneNumber, verifiedByPhoneNumber: true)
      return resolve(.success(response))
    }.eraseToAnyPublisher()
  }
}


public class WalletAuthRepo: AuthRepo {
  
  private var api: APIClient
  
  init(api: APIClient) {
    self.api = api
  }
  
  public func signup(with model: SignupRequest) -> AnyPublisher<SignupResponse, Error> {
    return Future { resolve in
      self.api.send(request: .signup(model: model) {  result in
        switch result {
        case .success(let response):
          resolve(.success(response))
        case .failure(let error):
          resolve(.failure(error))
        }
      })
    }.eraseToAnyPublisher()
  }
}
