//
//  CreateProfileViewController.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 13/03/1442 AH.
//

import UIKit

class CreateProfileViewController: RegisterationBaseViewController {
  // MARK:- CollectionView iVars
  enum FormSection: Int {
    case header
    case photo
    case details
  }
  
  enum FormRow {
    case header
    case photo
  }
  
  var dataSource: UICollectionViewDiffableDataSource<FormSection, FormRow>! = nil
  var onBoardingUI: OnBoardingUIController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureDataSource()
    submitButtonText = NSLocalizedString("CreateProfileViewController.ContinueButton", comment: "Continue Button")
  }
  
  // MARK: Actions
  @objc
  override func submitButtonTapped(_ button: UIButton) {
  }
}

// MARK:- DataSource
private extension CreateProfileViewController {
  func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource<FormSection, FormRow>(collectionView: collectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, item: FormRow) -> UICollectionViewCell? in
      // Return the cell.
      guard let section = FormSection(rawValue: indexPath.section) else {
        return nil
      }
      switch section {
      case .header:
        return collectionView.dequeueConfiguredReusableCell(using: self.titleCellRegistration, for: indexPath, item: item)
      case .photo:
        return collectionView.dequeueConfiguredReusableCell(using: self.profilePictureCellRegistration, for: indexPath, item: item)
      case .details:
        fatalError("not implemented")
      }
    }
    // load our initial data
    let snapshot = initialSnapshot()
    dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
  }
  
  func initialSnapshot() -> NSDiffableDataSourceSnapshot<FormSection, FormRow> {
    var snapshot = NSDiffableDataSourceSnapshot<FormSection, FormRow>()
    snapshot.appendSections([.header, .photo])
    snapshot.appendItems([.header], toSection: .header)
    snapshot.appendItems([.photo], toSection: .photo)
    return snapshot
  }
}

// MARK:- Cell Registration
private extension CreateProfileViewController {
  
  private var titleCellRegistration: UICollectionView.CellRegistration<TitleCell, FormRow> {
    return UICollectionView.CellRegistration<TitleCell, FormRow> { cell, indexPath, formRow in
      // Populate the cell with our item description.
      var contentConfiguration = TitleContentConfiguration()
      contentConfiguration.title = NSLocalizedString("CreateProfileViewController.HeaderText", comment: "")
      contentConfiguration.fontStyle = .largeTitle
      cell.titleContentConfiguration = contentConfiguration
      cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
    }
  }
  
  private var profilePictureCellRegistration: UICollectionView.CellRegistration<ProfilePictureCell, FormRow> {
    return UICollectionView.CellRegistration<ProfilePictureCell, FormRow> { cell, indexPath, formRow in
      // Populate the cell with our item description.
      var contentConfiguration = ProfilePictureContentConfiguration()
//      contentConfiguration.image =
      cell.profilePictureContentConfiguration = contentConfiguration
      cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
    }
  }

}

// MARK:- CollectionView Delegate
private extension CreateProfileViewController {
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
  }
}
