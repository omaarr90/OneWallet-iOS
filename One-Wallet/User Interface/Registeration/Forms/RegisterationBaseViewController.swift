//
//  FormViewController.swift
//  Teet
//
//  Created by Omar Alshammari on 25/01/1442 AH.
//  Copyright © 1442 Omar Alshammari. All rights reserved.
//

import UIKit

private extension UIButton {
  func addLoadingIndicator() {
    self.isEnabled = false
    let indicator = UIActivityIndicatorView(style: .medium)
    indicator.color = .white
    indicator.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(indicator)
    NSLayoutConstraint.activate([
      indicator.topAnchor.constraint(equalTo: self.topAnchor),
      indicator.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      indicator.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor, constant: LayoutGuide.Margine.defaultTrailing),
    ])
    indicator.startAnimating()
  }
}

class RegisterationBaseViewController: BaseCollectionViewController {
  
  var isLoading: Bool = false {
    didSet {
      self.reloadInputViews()
    }
  }
  var submitButton: UIButton?
  override var inputAccessoryView: UIView? {
    let submitButton = UIButton.init(frame: .init(x: 0, y: 0, width: 0, height: 40))
    submitButton.addTarget(self, action: #selector(submitButtonTapped(_:)), for: .touchUpInside)
    submitButton.backgroundColor = .systemBlue
    submitButton.setTitleColor(.white, for: .normal)
    submitButton.clipsToBounds = true
    submitButton.layer.cornerRadius = 6.0
    submitButton.setTitle(submitButtonText, for: .normal)
    if isLoading {
      submitButton.addLoadingIndicator()
    }
    
    self.submitButton = submitButton
    return SafeAreaInputAccessoryViewWrapperView(for: submitButton, color: .systemFill)
  }
  
  override var canBecomeFirstResponder: Bool { true }
  
  var submitButtonText: String = NSLocalizedString("FormViewController.submitButtonText.title", comment: "Default title for buttons inside forms") {
    didSet {
      self.reloadInputViews()
    }
  }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    configureCollectionView()
    self.collectionView.keyboardDismissMode = .interactive
  }
  
  override func generateLayout() -> UICollectionViewLayout {
    var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
    listConfiguration.showsSeparators = false
    listConfiguration.backgroundColor = .systemBackground
    let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
    return layout
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.becomeFirstResponder()
  }
  
  // MARK: Actions
  @objc
  func submitButtonTapped(_ button: UIButton) {
    fatalError("Implement in subclasses")
  }
  
  func setIsLoading(isLoading: Bool) {
    guard let button = submitButton else {
      return
    }
    button.isEnabled = !isLoading
    self.reloadInputViews()
  }
}

// MARK:- CollectionView Layout
extension RegisterationBaseViewController {
}

// MARK:- CollectionView DataSource
extension RegisterationBaseViewController {
}
