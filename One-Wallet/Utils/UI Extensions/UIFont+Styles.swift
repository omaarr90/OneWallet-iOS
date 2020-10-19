//
//  UIFont+Styles.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 02/03/1442 AH.
//

import UIKit

extension UIFont {
  func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
    let descriptor = fontDescriptor.withSymbolicTraits(traits)
    return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
  }
  
  func bold() -> UIFont {
    return withTraits(traits: .traitBold)
  }
  
  func italic() -> UIFont {
    return withTraits(traits: .traitItalic)
  }
  
  func semiBold() -> UIFont {
    let attributes = fontDescriptor.fontAttributes
    var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]
    
    traits[.weight] = UIFont.Weight.semibold

    let descriptor = fontDescriptor.addingAttributes([UIFontDescriptor.AttributeName.traits : traits])
    return UIFont(descriptor: descriptor, size: 0) //size 0 means keep the size as it is
  }
}
