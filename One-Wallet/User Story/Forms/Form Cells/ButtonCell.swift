//
//  ButtonCell.swift
//  Teet
//
//  Created by Omar Alshammari on 27/01/1442 AH.
//  Copyright © 1442 Omar Alshammari. All rights reserved.
//

import UIKit

class ButtonCell: UICollectionViewListCell {
  var buttonContentConfiguration: ButtonContentConfiguration? {
    didSet {
      setNeedsUpdateConfiguration()
    }
  }
  
  var button: UIButton? {
    guard let contentView = contentView as? ButtonContentView else {
      return nil
    }
    return contentView.button
  }
  
  override func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)
    
    contentConfiguration = buttonContentConfiguration
  }

}

struct ButtonContentConfiguration: UIContentConfiguration, Hashable {
  
  var title: String? = nil
  var backkgroundColor: UIColor?
  
  func makeContentView() -> UIView & UIContentView {
    return ButtonContentView(configuration: self)
  }
  
  func updated(for state: UIConfigurationState) -> Self {
    guard let state = state as? UICellConfigurationState else { return self }
    let updatedConfig = self
    if state.isSelected || state.isHighlighted {
      // Do something different?
    }
    return updatedConfig
  }
}

class ButtonContentView: UIView, UIContentView {
  init(configuration: ButtonContentConfiguration) {
    super.init(frame: .zero)
    setupInternalViews()
    apply(configuration: configuration)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  var configuration: UIContentConfiguration {
    get { appliedConfiguration }
    set {
      guard let newConfig = newValue as? ButtonContentConfiguration else { return }
      apply(configuration: newConfig)
    }
  }
  
  fileprivate let button = UIButton()
  
  private func setupInternalViews() {
    addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.clipsToBounds = true
    button.layer.cornerRadius = 8.0
    NSLayoutConstraint.activate([
      button.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      button.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
      button.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      button.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
      button.heightAnchor.constraint(equalToConstant: 44.0)

    ])
  }
  
  private var appliedConfiguration: ButtonContentConfiguration!
  
  private func apply(configuration: ButtonContentConfiguration) {
    guard appliedConfiguration != configuration else { return }
    appliedConfiguration = configuration
    
    
    button.setTitle(configuration.title, for: .normal)
    button.backgroundColor = configuration.backkgroundColor
  }
}
