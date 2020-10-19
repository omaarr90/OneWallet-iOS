//
//  FormViewController.swift
//  Teet
//
//  Created by Omar Alshammari on 25/01/1442 AH.
//  Copyright © 1442 Omar Alshammari. All rights reserved.
//

import UIKit

class FormViewController: UIViewController {
  
  var submitButton: UIButton?
  override var inputAccessoryView: UIView? {
    let submitButton = UIButton.init(frame: .init(x: 0, y: 0, width: 0, height: 40))
    submitButton.addTarget(self, action: #selector(submitButtonTapped(_:)), for: .touchUpInside)
    submitButton.backgroundColor = .systemBlue
    submitButton.setTitleColor(.white, for: .normal)
    submitButton.clipsToBounds = true
    submitButton.layer.cornerRadius = 6.0
    submitButton.setTitle(submitButtonText, for: .normal)
    
    self.submitButton = submitButton
    return SafeAreaInputAccessoryViewWrapperView(for: submitButton, color: .systemFill)
  }
  
  override var canBecomeFirstResponder: Bool { true }
  
  var submitButtonText: String = NSLocalizedString("FormViewController.submitButtonText.title", comment: "Default title for buttons inside forms") {
    didSet {
      guard let button = submitButton else {
        return
      }
      button.setTitle(submitButtonText, for: .normal)
    }
  }
  
  var formCollectionView: UICollectionView! = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureCollectionView()
    self.formCollectionView.keyboardDismissMode = .interactive
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
}

// MARK:- CollectionView Layout
extension FormViewController {
  
  func configureCollectionView() {
    let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: generateLayout())
    view.addSubview(collectionView)
    collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    collectionView.backgroundColor = .clear
    self.formCollectionView = collectionView
    collectionView.delegate = self
  }
  
  func generateLayout() -> UICollectionViewLayout {
    var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
    listConfiguration.showsSeparators = false
    listConfiguration.backgroundColor = .systemBackground
    let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
    return layout
  }
}

// MARK:- CollectionView DataSource
extension FormViewController {
}

// MARK:- CollectionView Delegate
extension FormViewController: UICollectionViewDelegate {}
