//
//  UIViewController+Alert.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 09/03/1442 AH.
//

import UIKit

public extension UIViewController {
  
  func alert(with title: String,
             message: String,
             preferredStyle: UIAlertController.Style,
             defaultActionTitle: String,
             primaryActionTitle: String?,
             primaryActionStyle: UIAlertAction.Style?,
             primaryHandler: ((UIAlertAction) -> Void)?,
             defaultHandler: ((UIAlertAction) -> Void)?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
    let defaultAction = UIAlertAction(title: defaultActionTitle, style: .default, handler: defaultHandler)
    if let primaryActionStyle = primaryActionStyle {
      let primaryAction = UIAlertAction(title: primaryActionTitle, style: primaryActionStyle, handler: primaryHandler)
      alert.addAction(primaryAction)
    }
    alert.addAction(defaultAction)
    self.present(alert, animated: true, completion: nil)
  }
  
  func errorAlert(with message: String) {
    self.alert(with: NSLocalizedString("Error", comment: ""),
               message: message,
               preferredStyle: .alert,
               defaultActionTitle: NSLocalizedString("O.K", comment: ""),
               primaryActionTitle: nil,
               primaryActionStyle: nil,
               primaryHandler: nil,
               defaultHandler: nil)
  }
}
