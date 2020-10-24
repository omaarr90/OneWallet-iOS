//
//  APIClient.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 05/03/1442 AH.
//

import Foundation

public struct APIClient {
  private let session: URLSession
  private let queue: DispatchQueue
  private var adapters: [RequestAdapter]
  
  init(configuration: URLSessionConfiguration = .default, adapters: [RequestAdapter] = [] ) {
    session = URLSession(configuration: configuration, delegate: NetworkManagerEvaluator(), delegateQueue: nil)
    queue = DispatchQueue(label: "Wallet-iOS-Networking", qos: .userInitiated, attributes: .concurrent)
    self.adapters = adapters
  }
  
  public func send(request: Request) {
    queue.async {
      var urlRequest = request.builder.toURLRequest()
      
      // Allow adapters to augment the request
      self.adapters.forEach { $0.adapt(&urlRequest) }
      // Before Send
      self.adapters.forEach { $0.beforeSend(urlRequest)}
      
      let task = session.dataTask(with: urlRequest) { data, response, error in
        self.adapters.forEach { $0.onResponse(response: response, data: data) }
        // keep a single result and dispatch it later on the main queue
        let result: Result<Data, APIError>
        if let error = error {
          result = .failure(.networkError(error))
        } else if let apiError = APIError.error(from: response) {
          result = .failure(apiError)
          
        }else {
          // since our success part takes a non-optional Data, we'll create an empty data if for some reason we have a nil
          result = .success(data ?? Data())
        }
        
        // notify adapters
        switch result {
        case .success:
          self.adapters.forEach { $0.onSuccess(request: urlRequest) }
        case .failure(let error):
          self.adapters.forEach { $0.onError(request: urlRequest, error: error) }
        }
        
        // callback on the main queue
        DispatchQueue.main.async {
          request.completion(result)
        }
      }
      task.resume()
    }
  }
}

public struct WalletService {
  // all endpoints will be based on this
  public static let baseURL = URL(string: "https://textsecure-service.whispersystems.org/")!
  public static var api: APIClient = {
    let configuration = URLSessionConfiguration.default
    //    configuration.httpAdditionalHeaders = [ "Authorization": "Bearer \(apiKey)"]
    return APIClient(configuration: configuration, adapters: [LoggerAdapter(), AuthAdapter()])
  }()
}

extension WalletService {
  struct LoggerAdapter: RequestAdapter {
    
    func beforeSend(_ request: URLRequest) {
      Logger.debug("about to send request: \(request)")
      Logger.verbose("Curl Command for \(String(describing: request.url?.absoluteString))\n\(request.curlString)\n")
    }
    
    func onSuccess(request: URLRequest) {
      Logger.info("Success request for: \(request)")
    }
    
    func onError(request: URLRequest, error: APIError) {
      Logger.error("Request failed: \(request) with error: \(error)")
    }
    
    func onResponse(response: URLResponse?, data: Data?) {
      Logger.info("Response recieved \(String(describing: response)) with data: \(String(describing: data))")
    }
    
    private func logCurl(for request: URLRequest) {
      
    }
  }
}

extension WalletService {
  struct AuthAdapter: RequestAdapter {
    func adapt(_ request: inout URLRequest) {
      //
      guard let basicAuth = try? KeychainManager.shared.getBasicAuth() else {
        Logger.debug("Not setting Authorization header for request \(request)")
        return
      }
      request.setValue("Basic \(basicAuth)", forHTTPHeaderField: "Authorization")
    }
  }
}
