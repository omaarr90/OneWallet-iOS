//
//  NetworkManagerEvaluator.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 05/03/1442 AH.
//

import Foundation

class NetworkManagerEvaluator: NSObject {
  
  let crtBase64 = "AMhf5ywVwITZMsff/eCyudZx9JDmkkkbV6PInzG4p8x3VqVJSFiMvnvlEKWuRob/1eaIetR31IYeAbm0NdOuHH8Qi+Rexi1wLlpzIo1gstHWBfZzy1+qHRV5A4TqPp15YzBPm0WSggW6PbSn+F4lf57VCnHF7p8SvzAA2ZZJPYJURt8X7bbg+H3i+PEjH9DXItNEqs2sNcug37xZQDLm7X0=="
  let host = "textsecure-service.whispersystems.org"
  
  private func pinnedCertificate() -> [Data] {
    guard let certData = Data(base64Encoded: crtBase64) else {
      return []
    }
    return [certData]
  }
}

extension NetworkManagerEvaluator: URLSessionTaskDelegate {
  
  func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    guard let trust = challenge.protectionSpace.serverTrust, SecTrustGetCertificateCount(trust) > 0  else {
      completionHandler(.performDefaultHandling, nil)
      return
    }
    
    guard let certificate = SecTrustGetCertificateAtIndex(trust, 0) else {
      completionHandler(.cancelAuthenticationChallenge, nil)
      return
    }
    
    let data = SecCertificateCopyData(certificate) as Data
    
    if self.pinnedCertificate().contains(data) {
      completionHandler(.useCredential, URLCredential(trust: trust))
    } else {
      #warning("Cancel, this is for debug only")
      completionHandler(.useCredential, URLCredential(trust: trust))
//      completionHandler(.cancelAuthenticationChallenge, nil)
    }
  }
}
