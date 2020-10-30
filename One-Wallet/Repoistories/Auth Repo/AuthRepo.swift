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

public struct VerifyPhoneNumberResponse: NetworkModel {
  let uuid: String
  var storageCapable: Bool
}

private extension Request {
  static func signup(model: SignupRequest, completion: @escaping (Result<Void, APIError>) -> Void) -> Request {
    Request.basic(baseURL: containersProvider.networkingProvider.backendService.baseURL,
                  path: "v1/accounts/\(model.transport)/code/\(model.phoneNumber)") { result in
      switch result {
      case .success(_):
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  
  static func verifyPhoneNumber(verificationCode: String, model: VerifyPhoneNumberRequest, completion: @escaping (Result<VerifyPhoneNumberResponse, APIError>) -> Void) -> Request {
    Request.post(method: .put,
                 baseURL: containersProvider.networkingProvider.backendService.baseURL,
                 path: "v1/accounts/code/\(verificationCode)",
                 body: model) { result in
      result.decoding(VerifyPhoneNumberResponse.self, completion: completion)
    }
  }
}

public protocol AuthRepo {
  func signup(with model: SignupRequest) -> AnyPublisher<Void, Error>
  func verifyPhoneNumber(verificationCode: String, model: VerifyPhoneNumberRequest) -> AnyPublisher<VerifyPhoneNumberResponse, Error>
}

public class MockAuthRepo: AuthRepo {
  public func verifyPhoneNumber(verificationCode: String, model: VerifyPhoneNumberRequest) -> AnyPublisher<VerifyPhoneNumberResponse, Error> {
    let response = VerifyPhoneNumberResponse(uuid: UUID().uuidString, storageCapable: false)
    return Future { resolve in
      return resolve(.success(response))
    }
    .delay(for: 1, scheduler: RunLoop.main)
    .eraseToAnyPublisher()
  }
  
  public func signup(with model: SignupRequest) -> AnyPublisher<Void, Error> {
    return Future { resolve in
      return resolve(.success(()))
    }
    .delay(for: 1, scheduler: RunLoop.main)
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
  
  public func verifyPhoneNumber(verificationCode: String, model: VerifyPhoneNumberRequest) -> AnyPublisher<VerifyPhoneNumberResponse, Error> {
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
