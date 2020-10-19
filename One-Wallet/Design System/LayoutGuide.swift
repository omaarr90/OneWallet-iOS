//
//  LayoutGuide.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 01/03/1442 AH.
//

import UIKit

struct LayoutGuide {
}

// MARK: Dimensions
extension LayoutGuide {
  struct Height {
    static let primaryControl: CGFloat = 52
  }
}


// MARK: Margines
extension LayoutGuide {
  struct Margine {
    static let defaultLeading: CGFloat = 8
    static let defaultTrailing: CGFloat = -8
    static let defaultTop: CGFloat = 8
    static let defaultBottom: CGFloat = -8
    
    
    static let titleLeading: CGFloat = defaultLeading
    static let titleTrailing: CGFloat = defaultTrailing
    static let titleTop: CGFloat = defaultTop * 2
    static let titleBottom: CGFloat = defaultBottom
  }
}
