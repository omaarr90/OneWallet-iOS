//
//  SignUpViewController.swift
//  Teet
//
//  Created by Omar Alshammari on 25/01/1442 AH.
//  Copyright © 1442 Omar Alshammari. All rights reserved.
//

import UIKit
import Combine

class SignUpViewController: RegisterationBaseViewController {
  
  // MARK:- CollectionView iVars
  enum FormSection: Int {
    case header
    case userDetails
  }
  
  enum FormRow {
    case title
    case phonNumber
  }
  
  var dataSource: UICollectionViewDiffableDataSource<FormSection, FormRow>! = nil
  
  // MARK:- Views
  private var phoneNumberTextField: UITextField?
  
  // MARK:- private iVars
  private lazy var viewModel: SignUpViewModel = {
    containersProvider.viewModelProvider.signUpViewModel
  }()
  
  private var tokens = Set<AnyCancellable>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    submitButtonText = NSLocalizedString("SignUpViewController.SignupButton.Title", comment: "Title for signup button")
    configureDataSource()
    configureObservers()
  }
  
  override func submitButtonTapped(_ button: UIButton) {
    Logger.info("")
//    guard let phoneNumber = phoneNumberTextField?.text else {
//      Logger.error("Missing Required Field")
//      return
//    }
    viewModel.signUp(phoneNumber: "+966557987731")
  }
}

// MARK:- View Controller State Management
private extension SignUpViewController {
  func isLoadingUpdated(isLoading: Bool) {
    self.isLoading = isLoading
    phoneNumberTextField?.isEnabled = !isLoading
    
    submitButtonText = isLoading ? NSLocalizedString("SignUpViewController.SignupButton.Title.Loading", comment: "Title for submit button when loading") : NSLocalizedString("SignUpViewController.SignupButton.Title", comment: "Title for signup button")
  }
  
  func errorReceived(error: Error) {
    self.errorAlert(with: error.localizedDescription)
  }
  
  func responseReceived() {
    let verifyViewController = VerifyPhoneNumberViewController()
    verifyViewController.phoneNumber = "+966557987731"
    self.navigationController?.pushViewController(verifyViewController, animated: true)
  }
}

// MARK:- DataSource
private extension SignUpViewController {
  func configureObservers() {
    viewModel.isLoading
      .receive(on: DispatchQueue.main)
      .sink { [weak self] isLoading in
        self?.isLoadingUpdated(isLoading: isLoading)
    }
      .store(in: &tokens)
    
    viewModel.error
      .receive(on: DispatchQueue.main)
      .sink { [weak self] error in
        guard let error = error else { return }
        self?.errorReceived(error: error)
    }.store(in: &tokens)
    
    viewModel.response
      .receive(on: DispatchQueue.main)
      .sink { [weak self] response in
      guard response != nil else { return }
        self?.responseReceived()
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
      case .userDetails:
        return collectionView.dequeueConfiguredReusableCell(using: self.textFieldCellRegistration, for: indexPath, item: item)
      case .header:
        return collectionView.dequeueConfiguredReusableCell(using: self.titleCellRegistration, for: indexPath, item: item)
      }
    }
    // load our initial data
    let snapshot = initialSnapshot()
    dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
  }
  
  func initialSnapshot() -> NSDiffableDataSourceSnapshot<FormSection, FormRow> {
    var snapshot = NSDiffableDataSourceSnapshot<FormSection, FormRow>()
    snapshot.appendSections([.header, .userDetails])
    snapshot.appendItems([.title], toSection: .header)
    snapshot.appendItems([.phonNumber], toSection: .userDetails)
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
      contentConfiguration.placeHolder = NSLocalizedString("SignUpViewController.PhoneNumberField.PlaceHolder", comment: "Place holder for phone number")
      cell.textFieldContentConfiguration = contentConfiguration
      cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
    }
  }
  
  private var titleCellRegistration: UICollectionView.CellRegistration<TitleCell, FormRow> {
    return UICollectionView.CellRegistration<TitleCell, FormRow> { cell, indexPath, formRow in
      // Populate the cell with our item description.
      var contentConfiguration = TitleContentConfiguration()
      contentConfiguration.title = NSLocalizedString("SignUpViewController.TitleText.text", comment: "Text for title")
      contentConfiguration.fontStyle = .title1
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
    
    switch item {
    case .phonNumber:
      self.phoneNumberTextField = textFieldCell?.textField
    case .title:
      break
    }
  }
}