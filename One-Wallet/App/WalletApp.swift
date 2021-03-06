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
    let rootView = SignUpViewController.init()
    window?.rootViewController = rootView
    window?.makeKeyAndVisible()
  }
}
