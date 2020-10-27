//
//  WalletUIController.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 10/03/1442 AH.
//

import UIKit

class WalletUIController {
  private let window: UIWindow
  
  private lazy var splitViewController: UISplitViewController = {
    let split = UISplitViewController(style: .tripleColumn)
    split.setViewController(ContactsViewController(), for: .primary)
    split.setViewController(HomeViewController(), for: .secondary)
    split.setViewController(SplashViewController(), for: .supplementary)
    split.setViewController(VerifyPhoneNumberViewController(), for: .compact)
    return split
  }()
  
  
  init(window: UIWindow) {
    self.window = window
  }
  
  func present() {
    window.rootViewController = self.splitViewController
    self.window.makeKeyAndVisible()
  }
}
