//
//  SplashViewController.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 27/02/1442 AH.
//

import UIKit

class SplashViewController: FormViewController {
  
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

  override func viewDidLoad() {
    super.viewDidLoad()
    configureDataSource()
    submitButtonText = NSLocalizedString("SplashViewController.ContinueButton", comment: "Continue Button")
  }
  
  // MARK: Actions
  @objc
  override func submitButtonTapped(_ button: UIButton) {
    self.navigationController?.pushViewController(SignUpViewController(), animated: true)
  }
}

// MARK:- DataSource
private extension SplashViewController {
  func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource<FormSection, FormRow>(collectionView: formCollectionView) {
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
private extension SplashViewController {
//  private var buttonCellRegistration: UICollectionView.CellRegistration<ButtonCell, FormRow> {
//    return UICollectionView.CellRegistration<ButtonCell, FormRow> { cell, indexPath, formRow in
//      // Populate the cell with our item description.
//      var contentConfiguration = ButtonContentConfiguration()
//      contentConfiguration.title = NSLocalizedString("SplashViewController.ContinueButton", comment: "Continue Button")
//      contentConfiguration.backkgroundColor = .systemBlue
//      cell.buttonContentConfiguration = contentConfiguration
//      cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
//    }
//  }
  
  private var titleCellRegistration: UICollectionView.CellRegistration<TitleCell, FormRow> {
    return UICollectionView.CellRegistration<TitleCell, FormRow> { cell, indexPath, formRow in
      // Populate the cell with our item description.
      var contentConfiguration = TitleContentConfiguration()
      if formRow == .text {
        contentConfiguration.title = NSLocalizedString("SplashViewController.ExplanationText", comment: "First screen welcoming text")
        contentConfiguration.fontStyle = .title2
      } else if formRow == .header {
        contentConfiguration.title = NSLocalizedString("SplashViewController.HeaderText", comment: "First screen header text")
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
      contentConfiguration.animation = "splash-wallet-animation"
      contentConfiguration.loopMode = .loop
      cell.animatedImageContentConfiguration = contentConfiguration
      cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
    }
  }
}

// MARK:- CollectionView Delegate
private extension SplashViewController {
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
  }
}
