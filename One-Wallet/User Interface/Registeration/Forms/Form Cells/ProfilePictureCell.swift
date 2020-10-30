//
//  ProfilePictureCell.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 13/03/1442 AH.
//

import UIKit

class ProfilePictureCell: UICollectionViewListCell {
  var profilePictureContentConfiguration: ProfilePictureContentConfiguration? {
    didSet {
      setNeedsUpdateConfiguration()
    }
  }
  
  
  override func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)
    
    contentConfiguration = profilePictureContentConfiguration
  }
  
}

struct ProfilePictureContentConfiguration: UIContentConfiguration, Hashable {
  
  var image: UIImage? = UIImage(systemName: "person.fill")
  
  func makeContentView() -> UIView & UIContentView {
    return ProfilePictureContentView(configuration: self)
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

class ProfilePictureContentView: UIView, UIContentView {
  init(configuration: ProfilePictureContentConfiguration) {
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
      guard let newConfig = newValue as? ProfilePictureContentConfiguration else { return }
      apply(configuration: newConfig)
    }
  }
  
  fileprivate let profilePicture = AvatarImageView()
  
  private func setupInternalViews() {
    addSubview(profilePicture)
    profilePicture.translatesAutoresizingMaskIntoConstraints = false
    
    let heightConstraint = profilePicture.heightAnchor.constraint(equalToConstant: 144)
    heightConstraint.priority = .defaultLow
    NSLayoutConstraint.activate([
      profilePicture.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
      profilePicture.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      profilePicture.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
      heightConstraint
    ])
  }
  
  private var appliedConfiguration: ProfilePictureContentConfiguration!
  
  private func apply(configuration: ProfilePictureContentConfiguration) {
    guard appliedConfiguration != configuration else { return }
    appliedConfiguration = configuration
    
    profilePicture.backgroundColor = .systemRed
//    profilePicture.setImageForName("Omar Alshammari", circular: true, textAttributes: nil)
  }
}
