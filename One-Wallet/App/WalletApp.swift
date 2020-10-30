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
  private var walletUI: WalletUIController?
  private var onBoardingUI: OnBoardingUIController?

  private init() {}
  
  func configure(with window: UIWindow?) {
    self.window = window
    self.walletUI = WalletUIController(window: window)
    self.onBoardingUI = OnBoardingUIController(window: window)
    ensureRootViewController()
  }
  
  func ensureRootViewController() {
    if let localAccount = WalletAccount.localAccount,
       localAccount.isRegistered {
      localAccount.isOnboarded ?  showHome() : showOnBoarding()
    } else {
      showRegistration()
    }
  }
  
  func showRegistration() {
    let navigationController = AuthNavigationController(rootViewController: SplashViewController())
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()
  }
  
  func showHome() {
    walletUI?.present()
  }
  
  func showOnBoarding() {
    onBoardingUI?.present()
  }

}
