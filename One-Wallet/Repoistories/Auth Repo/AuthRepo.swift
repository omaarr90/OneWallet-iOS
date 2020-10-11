//
//  AuthRepo.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 25/02/1442 AH.
//

import Foundation
import Combine

struct SignupRequest {
  let phoneNumber: String
  let firstName: String
  let lastName: String
  let password: String
  let confirmPassword: String
}

struct SignupResponse {
  let id: UUID
  let phoneNumber: String
  let firstName: String
  let lastName: String
  let verifiedByPhoneNumber: Bool
}

protocol AuthRepo {
  func signup(with model: SignupRequest) -> AnyPublisher<SignupResponse, Error>
}

class MockAuthRepo: AuthRepo {
  func signup(with model: SignupRequest) -> AnyPublisher<SignupResponse, Error> {
    return Future { resolve in
      let response = SignupResponse(id: UUID(), phoneNumber: model.phoneNumber, firstName: model.firstName, lastName: model.lastName, verifiedByPhoneNumber: true)
      return resolve(.success(response))
    }.eraseToAnyPublisher()
  }
}
