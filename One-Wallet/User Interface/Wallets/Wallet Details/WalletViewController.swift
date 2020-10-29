//
//  WalletViewController.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 10/03/1442 AH.
//

import UIKit

class WalletViewController: BaseCollectionViewController {
  
  var wallet: Wallet!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    self.title = wallet.name
  }
}
