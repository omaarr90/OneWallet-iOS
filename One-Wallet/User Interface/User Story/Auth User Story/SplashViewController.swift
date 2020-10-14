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
    case image
    case text
    case button
  }
  
  enum FormRow {
    case image
    case text
    case button
  }
  
  var dataSource: UICollectionViewDiffableDataSource<FormSection, FormRow>! = nil

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    configureDataSource()
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
      case .button:
        return collectionView.dequeueConfiguredReusableCell(using: self.buttonCellRegistration, for: indexPath, item: item)
      case .text:
        return collectionView.dequeueConfiguredReusableCell(using: self.titleCellRegistration, for: indexPath, item: item)
      case .image:
        return collectionView.dequeueConfiguredReusableCell(using: self.animatedImageCellRegistration, for: indexPath, item: item)
      }
    }
    // load our initial data
    let snapshot = initialSnapshot()
    dataSource.apply(snapshot)
  }
  
  func initialSnapshot() -> NSDiffableDataSourceSnapshot<FormSection, FormRow> {
    var snapshot = NSDiffableDataSourceSnapshot<FormSection, FormRow>()
    snapshot.appendSections([.image, .text, .button])
    snapshot.appendItems([.image], toSection: .image)
    snapshot.appendItems([.text], toSection: .text)
    snapshot.appendItems([.button], toSection: .button)
    return snapshot
  }
}

// MARK:- Cell Registration
private extension SplashViewController {
  private var buttonCellRegistration: UICollectionView.CellRegistration<ButtonCell, FormRow> {
    return UICollectionView.CellRegistration<ButtonCell, FormRow> { cell, indexPath, formRow in
      // Populate the cell with our item description.
      var contentConfiguration = ButtonContentConfiguration()
      contentConfiguration.title = NSLocalizedString("SplashViewController.ContinueButton", comment: "Continue Button")
      contentConfiguration.backkgroundColor = .systemBlue
      cell.buttonContentConfiguration = contentConfiguration
      cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
    }
  }
  
  private var titleCellRegistration: UICollectionView.CellRegistration<TitleCell, FormRow> {
    return UICollectionView.CellRegistration<TitleCell, FormRow> { cell, indexPath, formRow in
      // Populate the cell with our item description.
      var contentConfiguration = TitleContentConfiguration()
      contentConfiguration.title = NSLocalizedString("SplashViewController.ExplanationText", comment: "First screen welcoming text")
      contentConfiguration.fontStyle = .title2
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
    guard let item = dataSource.itemIdentifier(for: indexPath) else {
      return
    }
    
    let buttonCell = cell as? ButtonCell
    
    switch item {
    case .button:
      buttonCell?.button?.addTarget(self, action: #selector(continueButtonTapped(_:)), for: .touchUpInside)
    default:
      break
    }
  }
}
// MARK:- Actions
extension SplashViewController {
  @objc
  private func continueButtonTapped(_ sender: UIButton) {
    self.navigationController?.pushViewController(SignUpViewController(), animated: true)
  }
}
