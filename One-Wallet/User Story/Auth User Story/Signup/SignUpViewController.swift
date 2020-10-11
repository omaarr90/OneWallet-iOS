//
//  SignUpViewController.swift
//  Teet
//
//  Created by Omar Alshammari on 25/01/1442 AH.
//  Copyright © 1442 Omar Alshammari. All rights reserved.
//

import UIKit
import Combine

class SignUpViewController: FormViewController {
  
  // MARK:- CollectionView iVars
  enum FormSection: Int {
    case header
    case userDetails
    case password
    case button
  }
  
  enum FormRow {
    case title
    case phonNumber
    case firstName
    case lastName
    case password
    case confirmPassword
    case button
  }
  
  var dataSource: UICollectionViewDiffableDataSource<FormSection, FormRow>! = nil
  
  // MARK:- Views
  private var phoneNumberTextField: UITextField?
  private var firstNameTextField: UITextField?
  private var lastNameTextField: UITextField?
  private var passwordTextField: UITextField?
  private var confirmPasswordTextField: UITextField?
  
  // MARK:- private iVars
  private var viewModel = SignUpViewModel(authRepo: MockAuthRepo())
  private var tokens = Set<AnyCancellable>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureDataSource()
    configureObservers()
  }
}

// MARK:- DataSource
private extension SignUpViewController {
  func configureObservers() {
    viewModel.isLoading.sink { isLoading in
      Logger.debug("isLoading \(isLoading)")
    }.store(in: &tokens)
    
    viewModel.error.sink { error in
      Logger.error("error: \(String(describing: error))")
    }.store(in: &tokens)
    
    viewModel.response.sink { response in
      Logger.debug("response: \(String(describing: response))")
    }.store(in: &tokens)
  }
}

// MARK:- DataSource
private extension SignUpViewController {
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
      case .header:
        return collectionView.dequeueConfiguredReusableCell(using: self.titleCellRegistration, for: indexPath, item: item)
      }
    }
    // load our initial data
    let snapshot = initialSnapshot()
    dataSource.apply(snapshot)
  }
  
  func initialSnapshot() -> NSDiffableDataSourceSnapshot<FormSection, FormRow> {
    var snapshot = NSDiffableDataSourceSnapshot<FormSection, FormRow>()
    snapshot.appendSections([.header, .userDetails, .password, .button])
    snapshot.appendItems([.title], toSection: .header)
    snapshot.appendItems([.phonNumber, .firstName, .lastName], toSection: .userDetails)
    snapshot.appendItems([.password, .confirmPassword], toSection: .password)
    snapshot.appendItems([.button], toSection: .button)
    return snapshot
  }
}

// MARK:- Cell Registration
private extension SignUpViewController {
  private var textFieldCellRegistration: UICollectionView.CellRegistration<TextFieldCell, FormRow> {
    return UICollectionView.CellRegistration<TextFieldCell, FormRow> { cell, indexPath, formRow in
      // Populate the cell with our item description.
      var contentConfiguration = TextFieldContentConfiguration()
      contentConfiguration.borderStyle = .roundedRect
      switch formRow {
      case .phonNumber:
        contentConfiguration.placeHolder = NSLocalizedString("Phone number", comment: "")
      case .firstName:
        contentConfiguration.placeHolder = NSLocalizedString("First name", comment: "")
        self.firstNameTextField = cell.textField
      case .lastName:
        contentConfiguration.placeHolder = NSLocalizedString("Last name", comment: "")
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
      case .title:
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
  
  private var titleCellRegistration: UICollectionView.CellRegistration<TitleCell, FormRow> {
    return UICollectionView.CellRegistration<TitleCell, FormRow> { cell, indexPath, formRow in
      // Populate the cell with our item description.
      var contentConfiguration = TitleContentConfiguration()
      contentConfiguration.title = NSLocalizedString("One Wallet", comment: "")
      cell.titleContentConfiguration = contentConfiguration
      cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
    }
  }

}

// MARK:- CollectionView Delegate
private extension SignUpViewController {
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
    case .title:
      break
    }
  }
}
// MARK:- Actions
extension SignUpViewController {
  @objc
  private func signupButtonTapped(_ sender: UIButton) {
    Logger.info("")
    guard let phoneNumber = phoneNumberTextField?.text,
          let firstName = firstNameTextField?.text,
          let lastName = lastNameTextField?.text,
          let password = passwordTextField?.text,
          let confirmPassword = confirmPasswordTextField?.text else {
      Logger.error("Missing Required Field")
      return
    }
    
    viewModel.signUp(phoneNumber: phoneNumber, firstName: firstName, lastName: lastName, password: password, confirmPassword: confirmPassword)
  }
}
