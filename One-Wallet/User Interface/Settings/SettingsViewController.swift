//
//  SettingsViewController.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 12/03/1442 AH.
//

import UIKit

class SettingsViewController: BaseCollectionViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = NSLocalizedString("SettingsViewController.Title", comment: "")
    self.view.backgroundColor = .systemBackground
    configureNavigationItem()
  }
  
  private func configureNavigationItem() {
    let settingsItem = UIBarButtonItem(barButtonSystemItem: .close,
                                       target: self,
                                       action: #selector(settingsItemTapped(_:)))
    self.navigationItem.rightBarButtonItems = [settingsItem]
  }
  
  @objc
  func settingsItemTapped(_ sender: UIBarButtonItem) {
    Logger.info("")
    self.dismiss(animated: true, completion: nil)
  }
}
