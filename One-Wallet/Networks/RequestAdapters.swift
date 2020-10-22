//
//  RequestAdapters.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 05/03/1442 AH.
//

import Foundation

public protocol RequestAdapter {
  func adapt(_ request: inout URLRequest)
  func beforeSend(_ request: URLRequest)
  func onResponse(response: URLResponse?, data: Data?)
  func onError(request: URLRequest, error: APIError)
  func onSuccess(request: URLRequest)
}

public extension RequestAdapter {
  func adapt(_ request: inout URLRequest) { }
  func beforeSend(_ request: URLRequest) { }
  func onResponse(response: URLResponse?, data: Data?) { }
  func onError(request: URLRequest, error: APIError) { }
  func onSuccess(request: URLRequest) { }
}
