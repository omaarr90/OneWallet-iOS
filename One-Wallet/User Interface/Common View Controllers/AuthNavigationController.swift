//
//  AuthNavigationController.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 27/02/1442 AH.
//

import UIKit

class AuthNavigationController: WalletNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      self.setNavigationBarHidden(true, animated: false)
    }
}
