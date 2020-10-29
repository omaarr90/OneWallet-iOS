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
    case wallets
  }
  
  
  var dataSource: UICollectionViewDiffableDataSource<Section, Wallet>! = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = NSLocalizedString("WalletSidebarViewController.Row.wallets.description", comment: "")
    configureNavigationItem()
    configureDataSource()
  }
  
  private func configureNavigationItem() {
    let settingsItem = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                       landscapeImagePhone: UIImage(systemName: "gear"),
                                       style: .plain,
                                       target: self,
                                       action: #selector(settingsItemTapped(_:)))
    self.navigationItem.rightBarButtonItems = [settingsItem]
  }
  
  @objc
  func settingsItemTapped(_ sender: UIBarButtonItem) {
    Logger.info("")
    let nav = WalletNavigationController(rootViewController: SettingsViewController())
    self.present(nav, animated: true, completion: nil)
  }
}

// MARK:- DataSource
private extension WalletListViewController {
  func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource<Section, Wallet>(collectionView: collectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, item: Wallet) -> UICollectionViewCell? in
      // Return the cell.
      guard let section = Section(rawValue: indexPath.section) else {
        return nil
      }
      switch section {
      case .wallets:
        return collectionView.dequeueConfiguredReusableCell(using: self.titleCellRegistration, for: indexPath, item: item)
      }
    }
    // load our initial data
    let snapshot = initialSnapshot()
    dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
  }
  
  func initialSnapshot() -> NSDiffableDataSourceSnapshot<Section, Wallet> {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Wallet>()
    snapshot.appendSections([.wallets])
    snapshot.appendItems([], toSection: .wallets)
    return snapshot
  }
}

// MARK:- Cell Registration
private extension WalletListViewController {
  
  private var titleCellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, Wallet> {
    return UICollectionView.CellRegistration<UICollectionViewListCell, Wallet> { cell, indexPath, wallet in
      // Populate the cell with our item description.
      var contentConfiguration = cell.defaultContentConfiguration()
      contentConfiguration.text = wallet.name
      cell.contentConfiguration = contentConfiguration
    }
  }
  
}

// MARK:- CollectionView Delegate
private extension WalletListViewController {
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
  }
}
