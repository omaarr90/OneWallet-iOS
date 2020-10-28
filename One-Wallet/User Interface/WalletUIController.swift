//
//  WalletUIController.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 10/03/1442 AH.
//

import UIKit

class WalletUIController {
  private let window: UIWindow
    
  private var splitViewController: UISplitViewController
  
  // MARK:- Sidebar View Controllers
  private var sidebarController: WalletSidebarViewController
  private var walletListController: UIViewController
  
  // MARK:- Tabbar ViewControllers
  private var walletListNavigationController: UIViewController
  private var notificationsNavigationController: UIViewController
  private var settingsNavigationController: UIViewController
  
  private var tabBarController: UITabBarController

  init(window: UIWindow) {
    self.window = window
    
    let sidebarController = WalletSidebarViewController()
    self.sidebarController = sidebarController
    
    let walletListController = WalletListViewController()
    self.walletListController = walletListController
    
    
    let walletListNavigationController = WalletNavigationController(rootViewController: WalletListViewController())
    walletListNavigationController.tabBarItem = UITabBarItem(title: NSLocalizedString("WalletSidebarViewController.Row.wallets.description", comment: ""),
                                  image: UIImage(systemName: "creditcard"),
                                  selectedImage: UIImage(systemName: "creditcard"))
    self.walletListNavigationController = walletListNavigationController
    
    let notificationsNavigationController = WalletNavigationController(rootViewController: UIViewController())
    notificationsNavigationController.tabBarItem = UITabBarItem(title: NSLocalizedString("WalletSidebarViewController.Row.notifications.description", comment: ""),
                                  image: UIImage(systemName: "exclamationmark.triangle"),
                                  selectedImage: UIImage(systemName: "exclamationmark.triangle"))
    self.notificationsNavigationController = notificationsNavigationController
    
    let settingsNavigationController = WalletNavigationController(rootViewController: UIViewController())
    settingsNavigationController.tabBarItem = UITabBarItem(title: NSLocalizedString("WalletSidebarViewController.Row.settings.description", comment: ""),
                                  image: UIImage(systemName: "gear"),
                                  selectedImage: UIImage(systemName: "gear"))
    self.settingsNavigationController = settingsNavigationController
    
    let tabBarController = UITabBarController()
    tabBarController.viewControllers = [walletListNavigationController,
                                        notificationsNavigationController,
                                        settingsNavigationController]
    self.tabBarController = tabBarController

    let split = UISplitViewController(style: .tripleColumn)
    split.preferredSplitBehavior = .tile
    split.preferredDisplayMode = .oneBesideSecondary
    split.setViewController(sidebarController, for: .primary)
    split.setViewController(walletListController, for: .supplementary)
    split.setViewController(NoSelectedWalletViewController(), for: .secondary)
    split.setViewController(tabBarController, for: .compact)
    self.splitViewController = split

  }
  
  func present() {
    sidebarController.delegate = self
    window.rootViewController = self.splitViewController
    self.window.makeKeyAndVisible()
  }
}


extension WalletUIController: WalletSidebarViewControllerDelegate {
  func sidebarViewController(_ viewController: WalletSidebarViewController, didSelectOption option: WalletSidebarViewController.Option) {
    switch option {
    case .wallets:
      self.splitViewController.setViewController(walletListController, for: .supplementary)
      self.splitViewController.show(.secondary)
    case .notifications:
      break
    case .settings:
      break
    }
  }
}

private class NoSelectedWalletViewController: UIViewController {
  let titleLabel = UILabel()
  let bodyLabel = UILabel()
  let logoImageView = UIImageView()
  
  override func loadView() {
    view = UIView()
    
    let logoContainer = UIView()
    logoImageView.image = UIImage(systemName: "creditcard")
    logoImageView.translatesAutoresizingMaskIntoConstraints = false
    logoImageView.contentMode = .scaleAspectFit
    logoContainer.addSubview(logoImageView)
    NSLayoutConstraint.activate([
      logoImageView.topAnchor.constraint(equalTo: logoContainer.layoutMarginsGuide.topAnchor),
      logoImageView.bottomAnchor.constraint(equalTo: logoContainer.layoutMarginsGuide.bottomAnchor, constant: 8),
      logoImageView.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
      logoImageView.heightAnchor.constraint(equalToConstant: 72)
    ])
    
    titleLabel.font = UIFont.preferredFont(forTextStyle: .body).semiBold()
    titleLabel.textAlignment = .center
    titleLabel.numberOfLines = 0
    titleLabel.lineBreakMode = .byWordWrapping
    titleLabel.text = NSLocalizedString("NO_SELECTED_CONVERSATION_TITLE", comment: "Title welcoming to the app")
    
    bodyLabel.font = .preferredFont(forTextStyle: .body)
    bodyLabel.textAlignment = .center
    bodyLabel.numberOfLines = 0
    bodyLabel.lineBreakMode = .byWordWrapping
    bodyLabel.text = NSLocalizedString("NO_SELECTED_CONVERSATION_DESCRIPTION", comment: "Explanation of how to see a conversation.")
    
    let centerStackView = UIStackView(arrangedSubviews: [logoContainer, titleLabel, bodyLabel])
    centerStackView.translatesAutoresizingMaskIntoConstraints = false
    centerStackView.axis = .vertical
    centerStackView.spacing = 4
    view.addSubview(centerStackView)
    // Slightly offset from center to better optically center
    NSLayoutConstraint.activate([
      centerStackView.centerXAnchor.constraint(equalToSystemSpacingAfter: view.centerXAnchor, multiplier: 0.88),
      centerStackView.widthAnchor.constraint(equalTo: view.widthAnchor)
    ])
  }
}
