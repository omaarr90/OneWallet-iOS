//
//  NetworkResponses.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 05/03/1442 AH.
//

import Foundation

public extension Result where Success == Data, Failure == APIError {
  func decoding<M: NetworkModel>(_ model: M.Type, completion: @escaping (Result<M, APIError>) -> Void) {
    // decode the JSON in the background and call the completion block on the main thread
    DispatchQueue.global().async {
      let result = self.flatMap { data -> Result<M, APIError> in do {
        // get the decoder from the model's type
        let decoder = M.decoder
        // decode our data
        let model = try decoder.decode(M.self, from: data)
        return .success(model)
      } catch let e as DecodingError {
        // if we got a decoding error, wrap it in an APIError
        return .failure(.decodingError(e)) } catch {
          // probably won't happen, but Swift won't let us only catch decoding errors
          return .failure(APIError.unhandledResponse) }
      }
      
      DispatchQueue.main.async {
        completion(result)
      }
    }
  }
}
public protocol NetworkModel: Codable {
  // Models should provide their own decoders
  static var decoder: JSONDecoder { get }
  static var encoder: JSONEncoder { get }
}

public extension NetworkModel {
  static var decoder: JSONDecoder {
    let decoder = JSONDecoder()
    return decoder
  }
  
  static var encoder: JSONEncoder {
    let encoder = JSONEncoder()
    return encoder
  }
}

struct Movie: NetworkModel {
  let id: Int
  let title: String
  let posterPath: String
  let releaseDate: Date
}

struct PagedResults<T: NetworkModel>: NetworkModel {
  let page: Int
  let totalPages: Int
  let results: [T]
  
  static var decoder: JSONDecoder { T.decoder }
}
