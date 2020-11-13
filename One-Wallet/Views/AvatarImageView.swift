//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import UIKit

@objc
public class AvatarImageView: UIImageView {
  
  public init() {
    super.init(frame: .zero)
    self.configureView()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.configureView()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.configureView()
  }
  
  public override init(image: UIImage?) {
    super.init(image: image)
    self.configureView()
  }
  
  func configureView() {
    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      widthAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0)
    ])

    self.layer.minificationFilter = .trilinear
    self.layer.magnificationFilter = .trilinear
    self.layer.masksToBounds = true
    
    self.contentMode = .scaleToFill
  }
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = frame.size.width / 2
  }
}

/// Avatar View which updates itself as necessary when the profile, contact, or group picture changes.
@objc
public class ConversationAvatarImageView: AvatarImageView {
  
  var user: WalletUser
  let diameter: UInt
    
  required public init(thread: WalletUser, diameter: UInt) {
    self.user = thread
    self.diameter = diameter
    
    
    super.init(frame: .zero)
        
    self.updateImage()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  @objc func themeDidChange() {
    updateImage()
  }
  
  @objc func handleSignalAccountsChanged(notification: Notification) {
    Logger.debug("")
    
    // PERF: It would be nice if we could do this only if *this* user's SignalAccount changed,
    // but currently this is only a course grained notification.
    
    self.updateImage()
  }
  
  public func updateImage() {
    Logger.debug("updateImage")
    
    guard let imageData = user.contact?.imageData else {
      return
    }
    self.image = UIImage(data: imageData)//UIImage(systemName: "person.fill")//OWSAvatarBuilder.buildImage(thread: thread, diameter: diameter)
  }
}

@objc
public class AvatarImageButton: UIButton {
  
  // MARK: - Button Overrides
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    
    layer.cornerRadius = frame.size.width / 2
  }
  
  override public func setImage(_ image: UIImage?, for state: UIControl.State) {
    ensureViewConfigured()
    super.setImage(image, for: state)
  }
  
  // MARK: Private
  
  var hasBeenConfigured = false
  func ensureViewConfigured() {
    guard !hasBeenConfigured else {
      return
    }
    hasBeenConfigured = true
    
    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      widthAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0)
    ])
    
    layer.minificationFilter = .trilinear
    layer.magnificationFilter = .trilinear
    layer.masksToBounds = true
    
    contentMode = .scaleToFill
  }
}
