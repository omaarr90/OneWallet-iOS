//
//  VerifyPhoneNumberViewModel.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 02/03/1442 AH.
//

import Combine
import Security

class VerifyPhoneNumberViewModel {
  
  //MARK:- Dependencies
  private let authRepo: AuthRepo
  
  init(authRepo: AuthRepo) {
    self.authRepo = authRepo
  }
  
  //MARK:- Private Published Objects
  @Published private var _response: Void? = nil
  @Published private var _isLoading: Bool = false
  @Published private var _error: Error? = nil
  
  //MARK:- Published Objects as Publishers
  var response: AnyPublisher<Void?, Never> {
    return $_response.eraseToAnyPublisher()
  }
  var isLoading: AnyPublisher<Bool, Never> {
    return $_isLoading.eraseToAnyPublisher()
  }
  var error: AnyPublisher<Error?, Never> {
    return $_error.eraseToAnyPublisher()
  }
  
  //MARK:- Private iVars
  private var tokens: Set<AnyCancellable> = Set<AnyCancellable>()
  
  func verify(phoneNumber: String, verificationCode: String) {
    
    let authKey = self.generateServerAuthToken()
    let registrationID = self.generateRegistrationId()
    try? KeychainManager.shared.saveBasicAuthCredintials(username: phoneNumber, password: authKey)
    try? KeychainManager.shared.saveRegistrationID(registrationId: registrationID)
    let request = VerifyPhoneNumberRequest(registrationId: registrationID)
    self._isLoading = true
    authRepo.verifyPhoneNumber(verificationCode: verificationCode, model: request)
      .sink { completion in
        self._isLoading = false
        switch completion {
        case .finished:
          break
        case .failure(let error):
          self._error = error
        }
      } receiveValue: { response in
        self._response = response
      }
      .store(in: &tokens)
  }

  private func generateServerAuthToken() -> String {
    return Cryptography.generateRandomBytes(count: 16).hexadecimalString()
  }
  
  private func generateRegistrationId() -> UInt32 {
    let registrationID = arc4random_uniform(16380) + 1
    return registrationID
  }
  
}
