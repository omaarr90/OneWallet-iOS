//
//  SignUpViewController.swift
//  Teet
//
//  Created by Omar Alshammari on 25/01/1442 AH.
//  Copyright © 1442 Omar Alshammari. All rights reserved.
//

import UIKit

class SignUpViewController: FormViewController {
  
  enum FormSection: Int {
    case userDetails
    case password
    case button
  }
  
  enum FormRow {
    case phonNumber
    case firstName
    case lastName
    case password
    case confirmPassword
    case button
  }
  
  var dataSource: UICollectionViewDiffableDataSource<FormSection, FormRow>! = nil
  
  private var phoneNumberTextField: UITextField?
  private var firstNameTextField: UITextField?
  private var lastNameTextField: UITextField?
  private var passwordTextField: UITextField?
  private var confirmPasswordTextField: UITextField?
  
  var viewModel = SignUpViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureDataSource()
  }
}

// MARK:- DataSource
extension SignUpViewController {
  func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource<FormSection, FormRow>(collectionView: formCollectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, item: FormRow) -> UICollectionViewCell? in
      // Return the cell.
      guard let section = FormSection(rawValue: indexPath.section) else {
        return nil
      }
      switch section {
      case .userDetails, .password:
        return collectionView.dequeueConfiguredReusableCell(using: self.textFieldCellRegistration, for: indexPath, item: item)
      case .button:
        return collectionView.dequeueConfiguredReusableCell(using: self.buttonCellRegistration, for: indexPath, item: item)
      }
    }
    // load our initial data
    let snapshot = initialSnapshot()
    dataSource.apply(snapshot)
  }
  
  func initialSnapshot() -> NSDiffableDataSourceSnapshot<FormSection, FormRow> {
    var snapshot = NSDiffableDataSourceSnapshot<FormSection, FormRow>()
    snapshot.appendSections([.userDetails, .password, .button])
    snapshot.appendItems([.phonNumber, .firstName, .lastName], toSection: .userDetails)
    snapshot.appendItems([.password, .confirmPassword], toSection: .password)
    snapshot.appendItems([.button], toSection: .button)
    return snapshot
  }
}

// MARK:- Cell Registration
extension SignUpViewController {
  private var textFieldCellRegistration: UICollectionView.CellRegistration<TextFieldCell, FormRow> {
    return UICollectionView.CellRegistration<TextFieldCell, FormRow> { cell, indexPath, formRow in
      // Populate the cell with our item description.
      var contentConfiguration = TextFieldContentConfiguration()
      contentConfiguration.borderStyle = .roundedRect
      switch formRow {
      case .phonNumber:
        contentConfiguration.placeHolder = NSLocalizedString("Phone number", comment: "")
        contentConfiguration.image = UIImage(systemName: "square.and.arrow.up")
      case .firstName:
        contentConfiguration.placeHolder = NSLocalizedString("Username", comment: "")
        self.firstNameTextField = cell.textField
      case .lastName:
        contentConfiguration.placeHolder = NSLocalizedString("Email", comment: "")
        self.lastNameTextField = cell.textField
      case .password:
        contentConfiguration.placeHolder = NSLocalizedString("Password", comment: "")
        contentConfiguration.isSecureTextEntry = true
        self.passwordTextField = cell.textField
      case .confirmPassword:
        contentConfiguration.placeHolder = NSLocalizedString("Confirm password", comment: "")
        contentConfiguration.isSecureTextEntry = true
        self.confirmPasswordTextField = cell.textField
      case .button:
        break
      }
      
      cell.textFieldContentConfiguration = contentConfiguration
      cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
    }
  }

  private var buttonCellRegistration: UICollectionView.CellRegistration<ButtonCell, FormRow> {
    return UICollectionView.CellRegistration<ButtonCell, FormRow> { cell, indexPath, formRow in
      // Populate the cell with our item description.
      var contentConfiguration = ButtonContentConfiguration()
      contentConfiguration.title = NSLocalizedString("Signup", comment: "")
      contentConfiguration.backkgroundColor = .systemBlue
      cell.buttonContentConfiguration = contentConfiguration
      cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
    }
  }
}

// MARK:- CollectionView Delegate
extension SignUpViewController {
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    guard let item = dataSource.itemIdentifier(for: indexPath) else {
      return
    }
    
    let textFieldCell = cell as? TextFieldCell
    let buttonCell = cell as? ButtonCell
    
    switch item {
    case .phonNumber:
      self.phoneNumberTextField = textFieldCell?.textField
    case .firstName:
      self.firstNameTextField = textFieldCell?.textField
    case .lastName:
      self.lastNameTextField = textFieldCell?.textField
    case .password:
      self.passwordTextField = textFieldCell?.textField
    case .confirmPassword:
      self.confirmPasswordTextField = textFieldCell?.textField
    case .button:
      buttonCell?.button?.addTarget(self, action: #selector(signupButtonTapped(_:)), for: .touchUpInside)
    }
  }
}
// MARK:- Actions
extension SignUpViewController {
  @objc
  private func signupButtonTapped(_ sender: UIButton) {
    print("Signup button was tapped!")
  }
}
