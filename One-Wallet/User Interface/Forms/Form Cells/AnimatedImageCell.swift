//
//  AnimatedImageCell.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 27/02/1442 AH.
//

import UIKit
import Lottie

class AnimatedImageCell: UICollectionViewListCell {
  var animatedImageContentConfiguration: AnimatedImageContentConfiguration? {
    didSet {
      setNeedsUpdateConfiguration()
    }
  }
  
  
  override func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)
    
    contentConfiguration = animatedImageContentConfiguration
  }
  
}

struct AnimatedImageContentConfiguration: UIContentConfiguration, Hashable {
  
  var animation: String? = nil
  var loopMode: LottieLoopMode = .playOnce
  
  func makeContentView() -> UIView & UIContentView {
    return AnimatedImageContentView(configuration: self)
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

class AnimatedImageContentView: UIView, UIContentView {
  init(configuration: AnimatedImageContentConfiguration) {
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
      guard let newConfig = newValue as? AnimatedImageContentConfiguration else { return }
      apply(configuration: newConfig)
    }
  }
  
  fileprivate let animatedImage = AnimationView()
  
  private func setupInternalViews() {
    addSubview(animatedImage)
    animatedImage.translatesAutoresizingMaskIntoConstraints = false
    
    let heightConstraint = animatedImage.heightAnchor.constraint(equalToConstant: 144)
    heightConstraint.priority = .defaultLow
    NSLayoutConstraint.activate([
      animatedImage.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      animatedImage.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
      animatedImage.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      animatedImage.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
      heightConstraint
    ])
  }
  
  private var appliedConfiguration: AnimatedImageContentConfiguration!
  
  private func apply(configuration: AnimatedImageContentConfiguration) {
    guard appliedConfiguration != configuration else { return }
    appliedConfiguration = configuration
    
    guard let animationName = configuration.animation else {
      return
    }
    animatedImage.animation = Animation.named(animationName)
    animatedImage.loopMode = configuration.loopMode
    animatedImage.play()
  }
}
