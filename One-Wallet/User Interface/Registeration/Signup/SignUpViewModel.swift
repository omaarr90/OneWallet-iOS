//
//  SignUpViewModel.swift
//  Teet
//
//  Created by Omar Alshammari on 27/01/1442 AH.
//  Copyright © 1442 Omar Alshammari. All rights reserved.
//

import UIKit
import Combine

class SignUpViewModel {
  
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

  func signUp(phoneNumber: String) {
    
    let request = SignupRequest(phoneNumber: phoneNumber, transport: "sms")
    self._isLoading = true
    authRepo.signup(with: request)
      .sink { [weak self] completion in
        self?._isLoading = false
        switch completion {
        case .finished:
          break
        case .failure(let error):
          self?._error = error
        }
      } receiveValue: { [weak self] response in
        self?._response = response
      }
      .store(in: &tokens)
  }
}
