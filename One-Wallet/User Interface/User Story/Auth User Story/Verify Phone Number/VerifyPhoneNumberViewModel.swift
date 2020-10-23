//
//  VerifyPhoneNumberViewModel.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 02/03/1442 AH.
//

import Combine

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
    
    let request = VerifyPhoneNumberRequest(registrationId: "ss", signalingKey: "ss")
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

}
