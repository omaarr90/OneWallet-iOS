//
//  OnBoardingUIController.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 13/03/1442 AH.
//

import UIKit

class OnBoardingUIController {
  private let window: UIWindow?
  
  private lazy var permissionViewController: PermissionViewController = {
    let permission = PermissionViewController()
    permission.onBoardingUI = self
    return permission
  }()
  
  private lazy var createProfileViewController: CreateProfileViewController = {
    let profile = CreateProfileViewController()
    return profile
  }()

  private lazy var navigationController: UINavigationController = {
    return AuthNavigationController()
  }()

  init(window: UIWindow?) {
    self.window = window
  }
  
  func present() {
    navigationController.setViewControllers([permissionViewController], animated: true)
    window?.rootViewController = navigationController
    self.window?.makeKeyAndVisible()
  }

  func permissionDidComplete() {
    navigationController.setViewControllers([createProfileViewController], animated: true)
  }
}

