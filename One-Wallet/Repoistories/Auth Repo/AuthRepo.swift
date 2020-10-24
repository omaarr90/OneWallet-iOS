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

public struct VerifyPhoneNumberRequest: NetworkModel {
  let registrationId: UInt32
  var discoverableByPhoneNumber = false
}

private extension Request {
  static func signup(model: SignupRequest, completion: @escaping (Result<Void, APIError>) -> Void) -> Request {
    Request.basic(baseURL: WalletService.baseURL, path: "v1/accounts/\(model.transport)/code/\(model.phoneNumber)") { result in
      switch result {
      case .success(_):
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  
  static func verifyPhoneNumber(verificationCode: String, model: VerifyPhoneNumberRequest, completion: @escaping (Result<Void, APIError>) -> Void) -> Request {
    Request.post(method: .put, baseURL: WalletService.baseURL, path: "v1/accounts/code/\(verificationCode)", body: model) { result in
      switch result {
      case .success(_):
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}

public protocol AuthRepo {
  func signup(with model: SignupRequest) -> AnyPublisher<Void, Error>
  func verifyPhoneNumber(verificationCode: String, model: VerifyPhoneNumberRequest) -> AnyPublisher<Void, Error>
}

public class MockAuthRepo: AuthRepo {
  public func verifyPhoneNumber(verificationCode: String, model: VerifyPhoneNumberRequest) -> AnyPublisher<Void, Error> {
    return Future { resolve in
      return resolve(.success(()))
    }
    .delay(for: 5, scheduler: RunLoop.main)
    .eraseToAnyPublisher()
  }
  
  public func signup(with model: SignupRequest) -> AnyPublisher<Void, Error> {
    return Future { resolve in
      return resolve(.success(()))
    }
    .delay(for: 5, scheduler: RunLoop.main)
    .eraseToAnyPublisher()
  }
}


public class WalletAuthRepo: AuthRepo {
  
  private var api: APIClient
  
  init(api: APIClient) {
    self.api = api
  }
  
  public func signup(with model: SignupRequest) -> AnyPublisher<Void, Error> {
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
  
  public func verifyPhoneNumber(verificationCode: String, model: VerifyPhoneNumberRequest) -> AnyPublisher<Void, Error> {
    return Future { resolve in
      self.api.send(request: .verifyPhoneNumber(verificationCode: verificationCode, model: model) { result in
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
