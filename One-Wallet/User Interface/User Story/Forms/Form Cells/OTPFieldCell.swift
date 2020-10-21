//
//  OTPFieldCell.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 04/03/1442 AH.
//

import UIKit

class OTPFieldCell: UICollectionViewListCell {
  var otpFieldContentConfiguration: OTPFieldContentConfiguration? {
    didSet {
      setNeedsUpdateConfiguration()
    }
  }
  
  
  override func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)
    
    contentConfiguration = otpFieldContentConfiguration
  }
  
}

struct OTPFieldContentConfiguration: UIContentConfiguration, Hashable {
  
  var title: String? = nil
  var backkgroundColor: UIColor?
  var fontStyle: UIFont.TextStyle = .body
  
  func makeContentView() -> UIView & UIContentView {
    return OTPFieldContentView(configuration: self)
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

class OTPFieldContentView: UIView, UIContentView {
  init(configuration: OTPFieldContentConfiguration) {
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
      guard let newConfig = newValue as? OTPFieldContentConfiguration else { return }
      apply(configuration: newConfig)
    }
  }
  
  fileprivate let title = UILabel()
  
  private func setupInternalViews() {
    title.numberOfLines = 0
    addSubview(title)
    title.translatesAutoresizingMaskIntoConstraints = false
    title.clipsToBounds = true
    title.layer.cornerRadius = 8.0
    NSLayoutConstraint.activate([
      title.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      title.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
      title.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: LayoutGuide.Margine.titleTop),
      title.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
      
    ])
  }
  
  private var appliedConfiguration: OTPFieldContentConfiguration!
  
  private func apply(configuration: OTPFieldContentConfiguration) {
    guard appliedConfiguration != configuration else { return }
    appliedConfiguration = configuration
    
    title.font = UIFont.preferredFont(forTextStyle: configuration.fontStyle).semiBold()
    title.textAlignment = .center
    title.text = configuration.title
  }
}