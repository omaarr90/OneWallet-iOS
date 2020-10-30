//
//  PermissionViewController.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 13/03/1442 AH.
//

import UIKit
import Contacts

class PermissionViewController: RegisterationBaseViewController {
  // MARK:- CollectionView iVars
  enum FormSection: Int {
    case header
    case image
    case text
  }
  
  enum FormRow {
    case header
    case image
    case text
  }
  
  var dataSource: UICollectionViewDiffableDataSource<FormSection, FormRow>! = nil
  var onBoardingUI: OnBoardingUIController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureDataSource()
    submitButtonText = NSLocalizedString("PermissionViewController.ContinueButton", comment: "Continue Button")
  }
  
  // MARK: Actions
  @objc
  override func submitButtonTapped(_ button: UIButton) {
    requestContactsAccess()
  }
  
  private func requestContactsAccess() {
    Logger.info("")
    
    CNContactStore().requestAccess(for: CNEntityType.contacts) { [weak self] (granted, error) -> Void in
      if granted {
        Logger.info("Granted.")
      } else {
        Logger.error("Error: \(String(describing: error)).")
      }
      // Always fulfill.
      DispatchQueue.main.async {
        self?.onBoardingUI?.permissionDidComplete()
      }
    }
  }

}

// MARK:- DataSource
private extension PermissionViewController {
  func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource<FormSection, FormRow>(collectionView: collectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, item: FormRow) -> UICollectionViewCell? in
      // Return the cell.
      guard let section = FormSection(rawValue: indexPath.section) else {
        return nil
      }
      switch section {
      case .text:
        return collectionView.dequeueConfiguredReusableCell(using: self.titleCellRegistration, for: indexPath, item: item)
      case .image:
        return collectionView.dequeueConfiguredReusableCell(using: self.animatedImageCellRegistration, for: indexPath, item: item)
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
    snapshot.appendSections([.header, .image, .text])
    snapshot.appendItems([.header], toSection: .header)
    snapshot.appendItems([.image], toSection: .image)
    snapshot.appendItems([.text], toSection: .text)
    return snapshot
  }
}

// MARK:- Cell Registration
private extension PermissionViewController {
  
  private var titleCellRegistration: UICollectionView.CellRegistration<TitleCell, FormRow> {
    return UICollectionView.CellRegistration<TitleCell, FormRow> { cell, indexPath, formRow in
      // Populate the cell with our item description.
      var contentConfiguration = TitleContentConfiguration()
      if formRow == .text {
        contentConfiguration.title = NSLocalizedString("PermissionViewController.ExplanationText", comment: "Asking for Contact Permission")
        contentConfiguration.fontStyle = .title2
      } else if formRow == .header {
        contentConfiguration.title = NSLocalizedString("PermissionViewController.HeaderText", comment: "Asking for Contact Permission Explaination")
        contentConfiguration.fontStyle = .largeTitle
      }
      cell.titleContentConfiguration = contentConfiguration
      cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
    }
  }
  
  private var animatedImageCellRegistration: UICollectionView.CellRegistration<AnimatedImageCell, FormRow> {
    return UICollectionView.CellRegistration<AnimatedImageCell, FormRow> { cell, indexPath, formRow in
      // Populate the cell with our item description.
      var contentConfiguration = AnimatedImageContentConfiguration()
            
      contentConfiguration.animation = "contacts-permission"
      contentConfiguration.loopMode = .playOnce
      cell.animatedImageContentConfiguration = contentConfiguration
      cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
    }
  }
}

// MARK:- CollectionView Delegate
private extension PermissionViewController {
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
  }
}
