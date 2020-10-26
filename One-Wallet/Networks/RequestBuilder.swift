//
//  RequestBuilder.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 05/03/1442 AH.
//

import Foundation

public enum HTTPMethod: String {
  case get
  case post
  case put
  case delete
}

public protocol RequestBuilder {
  var method: HTTPMethod { get }
  var baseURL: URL { get }
  var path: String { get }
  var params: [URLQueryItem]? { get }
  var headers: [String: String] { get }
//  var authUsername: String? { get }
//  var authPassword: String? { get }
  func toURLRequest() -> URLRequest
  
  func encodeRequestBody() -> Data?
}

public extension RequestBuilder {
  func toURLRequest() -> URLRequest {
    var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
    components.queryItems = params
    let url = components.url!
    var request = URLRequest(url: url)
    request.allHTTPHeaderFields = headers
    request.httpMethod = method.rawValue.uppercased()
    request.httpBody = encodeRequestBody()
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    return request
  }
  
  // not all requests need body data
  func encodeRequestBody() -> Data? { nil }
}

public struct BasicRequestBuilder: RequestBuilder {
  public var method: HTTPMethod
  public var baseURL: URL
  public var path: String
  public var params: [URLQueryItem]?
  public var headers: [String: String] = [:]
//  public var authUsername: String?
//  public var authPassword: String?
}

public struct PostRequestBuilder<Body: NetworkModel>: RequestBuilder {
  public var method: HTTPMethod
  public var baseURL: URL
  public var path: String
  public var params: [URLQueryItem]?
  public var headers: [String: String] = [:]
//  public var authUsername: String?
//  public var authPassword: String?
  public var body: Body?
  
  init(method: HTTPMethod = .post,
       baseURL: URL,
       path: String,
       params: [URLQueryItem]? = nil,
       body: Body? = nil) {
    self.method = method
    self.baseURL = baseURL
    self.path = path
    self.params = params
    self.body = body
  }
  
  public func encodeRequestBody() -> Data? {
    guard let body = body else { return nil }
    do {
      let encoder = Body.encoder
      return try encoder.encode(body)
    } catch {
      assertionFailure("Error encoding request body: \(error)")
      return nil
    }
  }
}

public enum APIError: Error {
  // if our response is not an HTTPURLResponse
  case unknownResponse
  // The request could not be made (due to a timeout, missing connectivity, offline, etc). The associated value provides the underlying reason.
  case networkError(Error)
  // The request was made but the response indicated the request was invalid. This can be for missing params, missing authentication, etc. Associated value provides the HTTP Status Code. (HTTP 4xx)
  case requestError(Int)
  // The request was made but the response indicated the server had an error. Associated value provides the HTTP Status Code. (HTTP 5xx)
  case serverError(Int)
  // The response format could not be decoded into the expected type
  case decodingError(DecodingError)
  // catch all for something we should be handling!
  case unhandledResponse
}

extension APIError {
  static func error(from response: URLResponse?) -> APIError? {
    guard let http = response as? HTTPURLResponse else {
      return .unknownResponse
    }
    switch http.statusCode {
    // successful request
    case 200...299: return nil
    // request error
    case 400...499: return .requestError(http.statusCode)
    // server error
    case 500...599: return .serverError(http.statusCode)
    default: return .unhandledResponse
    }
  }
}

extension APIError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .unknownResponse:
      return NSLocalizedString("Error.unknownResponse.description", comment: "")
    case .networkError(_):
      return NSLocalizedString("Error.networkError.description", comment: "")
    case .requestError(_):
      return NSLocalizedString("Error.requestError.description", comment: "")
    case .serverError(_):
      return NSLocalizedString("Error.serverError.description", comment: "")
    case .decodingError(_):
      return NSLocalizedString("Error.decodingError.description", comment: "")
    case .unhandledResponse:
      return NSLocalizedString("Error.unhandledResponse.description", comment: "")
    }
  }
}

public struct Request {
  let builder: RequestBuilder
  let completion: (Result<Data, APIError>) -> Void
  init(builder: RequestBuilder, completion: @escaping (Result<Data, APIError>) -> Void) {
    self.builder = builder
    self.completion = completion
  }
}

public extension Request {
  static func basic(method: HTTPMethod = .get,
                           baseURL: URL,
                           path: String,
                           params: [URLQueryItem]? = nil,
                           completion: @escaping (Result<Data, APIError>) -> Void) -> Request {
    let builder = BasicRequestBuilder(method: method, baseURL: baseURL, path: path, params: params)
    return Request(builder: builder, completion: completion)
  }

  static func post<Body: NetworkModel>(method: HTTPMethod = .post,
                                       baseURL: URL,
                                       path: String,
                                       params: [URLQueryItem]? = nil,
                                       body: Body?,
                                       completion: @escaping (Result<Data, APIError>) -> Void) -> Request {
    let builder = PostRequestBuilder(method: method, baseURL: baseURL, path: path, params: params, body: body)
    return Request(builder: builder, completion: completion)
  }
}
