//
//  WalletUIController.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 10/03/1442 AH.
//

import UIKit
import Lottie

class WalletUIController {
  private let window: UIWindow?
    
  private var splitViewController: UISplitViewController
  
  // MARK:- Sidebar View Controllers
  private var walletListController: WalletListViewController
  private var compactWalletListController: WalletListViewController

  private var walletListNavigationController: UINavigationController
  
  private var selectWalletDetails: WalletViewController?

  init(window: UIWindow?) {
    self.window = window
        
    self.walletListController = Self.createWalletList()
    self.walletListController.purpose = .primary
    
    self.compactWalletListController = Self.createWalletList()
    self.compactWalletListController.purpose = .compact
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
    self.walletListController.delegate = self
    self.compactWalletListController.delegate = self
    self.splitViewController.delegate = self
    window?.rootViewController = self.splitViewController
    self.window?.makeKeyAndVisible()
  }
  
  private static func createWalletList() -> WalletListViewController {
    return WalletListViewController()
  }
}

extension WalletUIController: WalletListViewControllerDelegate {
  func walletListViewController(_ walletListViewController: WalletListViewController, didSelectWallet wallet: Wallet) {
    let walletViewController = WalletViewController()
    walletViewController.wallet = wallet
    
    if let selectWalletDetails = self.selectWalletDetails,
       selectWalletDetails == walletViewController {
      Logger.debug("Not showing the same wallet again!")
      return
    }
    
    self.splitViewController.setViewController(nil, for: .secondary)
    self.splitViewController.setViewController(walletViewController, for: .secondary)
    self.walletListNavigationController.setViewControllers([self.compactWalletListController, walletViewController], animated: true)

    self.selectWalletDetails = walletViewController
  }
}

extension WalletUIController: UISplitViewControllerDelegate {
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
