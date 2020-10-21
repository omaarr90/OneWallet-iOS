//
//  WalletApp.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 01/02/1442 AH.
//

import UIKit

final class WalletApp {
  static let shared = WalletApp()
  private var window: UIWindow?
  
  private init() {}
  
  func configure(with window: UIWindow?) {
    self.window = window
    let navigationController = AuthNavigationController(rootViewController: SplashViewController())
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()
  }
  
  func showHome() {
    guard let window = self.window else {
      fatalError("Root Window not set")
    }
    
    let home = HomeViewController()
    window.rootViewController = home
    window.makeKeyAndVisible()
  }
}
