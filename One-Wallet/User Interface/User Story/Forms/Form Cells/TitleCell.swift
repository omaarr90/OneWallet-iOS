//
//  TitleCell.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 19/02/1442 AH.
//

import UIKit

class TitleCell: UICollectionViewListCell {
  var titleContentConfiguration: TitleContentConfiguration? {
    didSet {
      setNeedsUpdateConfiguration()
    }
  }
  
  
  override func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)
    
    contentConfiguration = titleContentConfiguration
  }
  
}

struct TitleContentConfiguration: UIContentConfiguration, Hashable {
  
  var title: String? = nil
  var backkgroundColor: UIColor?
  
  func makeContentView() -> UIView & UIContentView {
    return TitleContentView(configuration: self)
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

class TitleContentView: UIView, UIContentView {
  init(configuration: TitleContentConfiguration) {
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
      guard let newConfig = newValue as? TitleContentConfiguration else { return }
      apply(configuration: newConfig)
    }
  }
  
  fileprivate let title = UILabel()
  
  private func setupInternalViews() {
    addSubview(title)
    title.translatesAutoresizingMaskIntoConstraints = false
    title.clipsToBounds = true
    title.layer.cornerRadius = 8.0
    NSLayoutConstraint.activate([
      title.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      title.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
      title.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      title.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
      title.heightAnchor.constraint(equalToConstant: 44.0)
      
    ])
  }
  
  private var appliedConfiguration: TitleContentConfiguration!
  
  private func apply(configuration: TitleContentConfiguration) {
    guard appliedConfiguration != configuration else { return }
    appliedConfiguration = configuration
    
    title.font = UIFont.preferredFont(forTextStyle: .title1)
    title.textAlignment = .center
    title.text = configuration.title
  }
}
