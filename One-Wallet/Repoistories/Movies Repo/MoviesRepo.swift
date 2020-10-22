//
//  MoviesRepo.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 05/03/1442 AH.
//

import Foundation

extension Request {
  static func popularMovies(completion: @escaping (Result<PagedResults<Movie>, APIError>) -> Void) -> Request {
    Request.basic(baseURL: WalletService.baseURL, path: "discover/ movie", params: [
                    URLQueryItem(name: "sort_by", value: "popularity.desc") ]) { result in
      result.decoding(PagedResults<Movie>.self, completion: completion)
    }
  }
}
