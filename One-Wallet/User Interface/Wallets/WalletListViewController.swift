//
//  WalletListViewController.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 10/03/1442 AH.
//

import UIKit

class WalletListViewController: BaseCollectionViewController {
  // MARK:- CollectionView iVars
  enum Section: Int {
    case test
  }
  
  enum Row {
    case test
  }
  
  var dataSource: UICollectionViewDiffableDataSource<Section, Row>! = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = NSLocalizedString("WalletSidebarViewController.Row.wallets.description", comment: "")
    self.view.backgroundColor = .systemRed
    configureDataSource()
  }
}

// MARK:- DataSource
private extension WalletListViewController {
  func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource<Section, Row>(collectionView: collectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, item: Row) -> UICollectionViewCell? in
      // Return the cell.
      guard let section = Section(rawValue: indexPath.section) else {
        return nil
      }
      switch section {
      case .test:
        return collectionView.dequeueConfiguredReusableCell(using: self.titleCellRegistration, for: indexPath, item: item)
      }
    }
    // load our initial data
    let snapshot = initialSnapshot()
    dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
  }
  
  func initialSnapshot() -> NSDiffableDataSourceSnapshot<Section, Row> {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
    snapshot.appendSections([.test])
    snapshot.appendItems([.test], toSection: .test)
    return snapshot
  }
}

// MARK:- Cell Registration
private extension WalletListViewController {
  
  private var titleCellRegistration: UICollectionView.CellRegistration<TitleCell, Row> {
    return UICollectionView.CellRegistration<TitleCell, Row> { cell, indexPath, formRow in
      // Populate the cell with our item description.
      var contentConfiguration = TitleContentConfiguration()
      contentConfiguration.title = "Wallet List"
      contentConfiguration.fontStyle = .largeTitle
      cell.titleContentConfiguration = contentConfiguration
      cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
    }
  }
  
}

// MARK:- CollectionView Delegate
private extension WalletListViewController {
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
  }
}
