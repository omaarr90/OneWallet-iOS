//
//  VerifyPhoneNumberViewController.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 02/03/1442 AH.
//

import UIKit
import Combine

class VerifyPhoneNumberViewController: FormViewController {

  
  // MARK:- CollectionView iVars
  enum FormSection: Int {
    case header
    case input
    case footer
  }
  
  enum FormRow {
    case title
    case wrongNumber
    case otp
    case countDown
    case requestCode
  }
  
  var dataSource: UICollectionViewDiffableDataSource<FormSection, FormRow>! = nil
  
  // MARK:- Views
  private var otpTextField: UITextField?

  // MARK:- private iVars
  private var viewModel = VerifyPhoneNumberViewModel(authRepo: MockAuthRepo())
  private var tokens = Set<AnyCancellable>()
  var phoneNumber: String!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    self.submitButtonText = NSLocalizedString("VerifyPhoneNumberViewController.SubmitButton.Title", comment: "Title for submit button button")
    configureDataSource()
  }
  
  override func submitButtonTapped(_ button: UIButton) {
    Logger.info("")
  }
}

// MARK:- DataSource
private extension VerifyPhoneNumberViewController {
  func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource<FormSection, FormRow>(collectionView: formCollectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, item: FormRow) -> UICollectionViewCell? in
      // Return the cell.
      guard let section = FormSection(rawValue: indexPath.section) else {
        return nil
      }
      switch section {
      case .header:
        if item == .title {
          return collectionView.dequeueConfiguredReusableCell(using: self.titleCellRegistration, for: indexPath, item: item)
        } else {
          return collectionView.dequeueConfiguredReusableCell(using: self.buttonCellRegistration, for: indexPath, item: item)
        }
      case .input:
        return collectionView.dequeueConfiguredReusableCell(using: self.textFieldCellRegistration, for: indexPath, item: item)
      case .footer:
        return collectionView.dequeueConfiguredReusableCell(using: self.buttonCellRegistration, for: indexPath, item: item)
      }
    }
    // load our initial data
    let snapshot = initialSnapshot()
    dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
  }
  
  func initialSnapshot() -> NSDiffableDataSourceSnapshot<FormSection, FormRow> {
    var snapshot = NSDiffableDataSourceSnapshot<FormSection, FormRow>()
    snapshot.appendSections([.header, .input, .footer])
    snapshot.appendItems([.title, .wrongNumber], toSection: .header)
    snapshot.appendItems([.otp], toSection: .input)
    snapshot.appendItems([.requestCode], toSection: .footer)
    return snapshot
  }
}

// MARK:- Cell Registration
private extension VerifyPhoneNumberViewController {
  private var textFieldCellRegistration: UICollectionView.CellRegistration<TextFieldCell, FormRow> {
    return UICollectionView.CellRegistration<TextFieldCell, FormRow> { cell, indexPath, formRow in
      // Populate the cell with our item description.
      var contentConfiguration = TextFieldContentConfiguration()
      contentConfiguration.borderStyle = .roundedRect
      contentConfiguration.placeHolder = NSLocalizedString("VerifyPhoneNumberViewController.OTPField.PlaceHolder", comment: "Place holder for otp")
      cell.textFieldContentConfiguration = contentConfiguration
      cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
    }
  }
  
    private var buttonCellRegistration: UICollectionView.CellRegistration<ButtonCell, FormRow> {
      return UICollectionView.CellRegistration<ButtonCell, FormRow> { cell, indexPath, formRow in
        // Populate the cell with our item description.
        var contentConfiguration = ButtonContentConfiguration()
        if formRow == .wrongNumber {
          contentConfiguration.title = NSLocalizedString("VerifyPhoneNumberViewController.WrongNumber.Title", comment: "Title for wrong number button")
        } else {
          contentConfiguration.title = NSLocalizedString("VerifyPhoneNumberViewController.RequestCode.Title", comment: "Title for request code again button")
        }
        contentConfiguration.backkgroundColor = .clear
        contentConfiguration.titleColor = .systemBlue
        cell.buttonContentConfiguration = contentConfiguration
        cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
      }
    }
  
  private var titleCellRegistration: UICollectionView.CellRegistration<TitleCell, FormRow> {
    return UICollectionView.CellRegistration<TitleCell, FormRow> { cell, indexPath, formRow in
      // Populate the cell with our item description.
      var contentConfiguration = TitleContentConfiguration()
      let title = NSLocalizedString("VerifyPhoneNumberViewController.TitleText.text", comment: "Text for title")
      contentConfiguration.title = "\(title) \(self.phoneNumber!)"
      contentConfiguration.fontStyle = .title1
      cell.titleContentConfiguration = contentConfiguration
      cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
    }
  }
  
}

// MARK:- CollectionView Delegate
private extension VerifyPhoneNumberViewController {
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    guard let item = dataSource.itemIdentifier(for: indexPath) else {
      return
    }
    
    let textFieldCell = cell as? TextFieldCell
    let buttonCell = cell as? ButtonCell

    switch item {
    case .otp:
      self.otpTextField = textFieldCell?.textField
    case .title:
      break
    case .wrongNumber:
      buttonCell?.button?.addTarget(self, action: #selector(wrongNumberTapped(sender:)), for: .touchUpInside)
    case .countDown:
      break
    case .requestCode:
      break
    }
  }
}

private extension VerifyPhoneNumberViewController {
  @objc func wrongNumberTapped(sender: UIButton) {
    self.navigationController?.popViewController(animated: true)
  }
}
