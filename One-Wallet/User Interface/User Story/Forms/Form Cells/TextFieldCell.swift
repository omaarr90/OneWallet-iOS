//
//  TextFieldCell.swift
//  Teet
//
//  Created by Omar Alshammari on 25/01/1442 AH.
//  Copyright © 1442 Omar Alshammari. All rights reserved.
//

import UIKit

class TextFieldCell: UICollectionViewListCell {
  var textFieldContentConfiguration: TextFieldContentConfiguration? {
    didSet {
      setNeedsUpdateConfiguration()
    }
  }
  
  var textField: UITextField? {
    guard let contentView = contentView as? TextFieldContentView else {
      return nil
    }
    return contentView.textField
  }
  
  override func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)
    
    contentConfiguration = textFieldContentConfiguration
  }
}

struct TextFieldContentConfiguration: UIContentConfiguration, Hashable {
  
  var placeHolder: String? = nil
  var borderStyle: UITextField.BorderStyle = .none
  var delegate: UITextFieldDelegate? = nil
  var isSecureTextEntry: Bool = false
  
  func makeContentView() -> UIView & UIContentView {
    return TextFieldContentView(configuration: self)
  }
  
  func updated(for state: UIConfigurationState) -> Self {
    guard let state = state as? UICellConfigurationState else { return self }
    let updatedConfig = self
    if state.isSelected || state.isHighlighted {
      // Do something different?
    }
    return updatedConfig
  }
  
  static func == (lhs: TextFieldContentConfiguration, rhs: TextFieldContentConfiguration) -> Bool {
    return lhs.placeHolder == rhs.placeHolder &&
      lhs.borderStyle == rhs.borderStyle &&
      lhs.isSecureTextEntry == rhs.isSecureTextEntry
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(placeHolder)
    hasher.combine(borderStyle)
    hasher.combine(isSecureTextEntry)
  }
}

class TextFieldContentView: UIView, UIContentView {
  init(configuration: TextFieldContentConfiguration) {
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
      guard let newConfig = newValue as? TextFieldContentConfiguration else { return }
      apply(configuration: newConfig)
    }
  }
  
  fileprivate let textField = UITextField()
  
  private func setupInternalViews() {
    addSubview(textField)
    textField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      textField.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      textField.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
      textField.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      textField.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
      textField.heightAnchor.constraint(equalToConstant: 44.0)
    ])
  }
  
  private var appliedConfiguration: TextFieldContentConfiguration!
  
  private func apply(configuration: TextFieldContentConfiguration) {
    guard appliedConfiguration != configuration else { return }
    appliedConfiguration = configuration
    
    textField.placeholder = configuration.placeHolder
    textField.borderStyle = configuration.borderStyle
    textField.delegate = configuration.delegate
    textField.isSecureTextEntry = configuration.isSecureTextEntry
  }
}
