//
//  WalletUIController.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 10/03/1442 AH.
//

import UIKit
import Lottie

class WalletUIController {
  private let window: UIWindow
    
  private var splitViewController: UISplitViewController
  
  // MARK:- Sidebar View Controllers
  private var sidebarController: WalletSidebarViewController
  private var walletListController: UIViewController
  private var compactWalletListController: UIViewController

  private var walletListNavigationController: UINavigationController

  init(window: UIWindow) {
    self.window = window
    
    self.sidebarController = WalletSidebarViewController()
    
    self.walletListController = Self.createWalletList()
    
    self.compactWalletListController = Self.createWalletList()
    self.walletListNavigationController = WalletNavigationController(rootViewController: self.compactWalletListController)

    self.splitViewController = UISplitViewController(style: .doubleColumn)
    splitViewController.preferredSplitBehavior = .tile
    splitViewController.preferredDisplayMode = .oneBesideSecondary
    
    splitViewController.setViewController(self.walletListController,
                                          for: .primary)
    splitViewController.setViewController(walletListNavigationController,
                                          for: .compact)
    
    splitViewController.setViewController(NoSelectedWalletViewController(), for: .secondary)
  }
  
  func present() {
    sidebarController.delegate = self
    window.rootViewController = self.splitViewController
    self.window.makeKeyAndVisible()
  }
  
  private static func createWalletList() -> WalletListViewController {
    return WalletListViewController()
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
  let logoImageView = AnimationView()
  
  override func loadView() {
    view = UIView()
    
    let logoContainer = UIView()
    logoImageView.animation = Animation.named("splash-wallet-animation")
    logoImageView.loopMode = .loop
    logoImageView.play()
    logoImageView.translatesAutoresizingMaskIntoConstraints = false
    logoImageView.contentMode = .scaleAspectFit
    logoContainer.addSubview(logoImageView)
    NSLayoutConstraint.activate([
      logoImageView.topAnchor.constraint(equalTo: logoContainer.layoutMarginsGuide.topAnchor),
      logoImageView.bottomAnchor.constraint(equalTo: logoContainer.layoutMarginsGuide.bottomAnchor, constant: 8),
      logoImageView.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
      logoImageView.heightAnchor.constraint(equalToConstant: 144)
    ])
    
    titleLabel.font = UIFont.preferredFont(forTextStyle: .body).semiBold()
    titleLabel.textAlignment = .center
    titleLabel.numberOfLines = 0
    titleLabel.lineBreakMode = .byWordWrapping
    titleLabel.text = NSLocalizedString("NO_SELECTED_WALLET_TITLE", comment: "Title welcoming to the app")
    
    bodyLabel.font = .preferredFont(forTextStyle: .body)
    bodyLabel.textAlignment = .center
    bodyLabel.numberOfLines = 0
    bodyLabel.lineBreakMode = .byWordWrapping
    bodyLabel.text = NSLocalizedString("NO_SELECTED_WALLET_DESCRIPTION", comment: "Explanation of how to see a conversation.")
    
    let centerStackView = UIStackView(arrangedSubviews: [logoContainer, titleLabel, bodyLabel])
    centerStackView.translatesAutoresizingMaskIntoConstraints = false
    centerStackView.axis = .vertical
    centerStackView.spacing = 24
    view.addSubview(centerStackView)
    // Slightly offset from center to better optically center
    NSLayoutConstraint.activate([
      centerStackView.centerXAnchor.constraint(equalToSystemSpacingAfter: view.centerXAnchor, multiplier: 0.88),
      centerStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      centerStackView.widthAnchor.constraint(equalTo: view.widthAnchor)
    ])
  }
}
