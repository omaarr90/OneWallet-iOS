//
//  WalletSidebarViewController.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 10/03/1442 AH.
//

import UIKit

protocol WalletSidebarViewControllerDelegate: class {
  func sidebarViewController(_ viewController: WalletSidebarViewController, didSelectOption option: WalletSidebarViewController.Option)
}

class WalletSidebarViewController: BaseCollectionViewController {
  
  // MARK:- CollectionView iVars
  enum Section: Int {
    case main
  }
  
  enum Option {
    case wallets
    case notifications
    case settings
  }
  
  var dataSource: UICollectionViewDiffableDataSource<Section, Option>! = nil
  var delegate: WalletSidebarViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureDataSource()
  }
  
  // MARK:- CollectionView Override
  override func generateLayout() -> UICollectionViewLayout {
    var listConfiguration = UICollectionLayoutListConfiguration(appearance: .sidebar)
    listConfiguration.showsSeparators = true
    let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
    return layout
  }
}

// MARK:- CollectionView Delegate
extension WalletSidebarViewController {
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let option = dataSource.itemIdentifier(for: indexPath) else {
      assertionFailure("unknown row selected")
      return
    }
    self.delegate?.sidebarViewController(self, didSelectOption: option)
  }
}


// MARK:- DataSource
private extension WalletSidebarViewController {
  func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource<Section, Option>(collectionView: collectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, item: Option) -> UICollectionViewCell? in
      // Return the cell.
      guard let section = Section(rawValue: indexPath.section) else {
        return nil
      }
      switch section {
      case .main:
        return collectionView.dequeueConfiguredReusableCell(using: self.cellRegistration, for: indexPath, item: item)
      }
    }
    // load our initial data
    let snapshot = initialSnapshot()
    dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
  }
  
  func initialSnapshot() -> NSDiffableDataSourceSnapshot<Section, Option> {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Option>()
    snapshot.appendSections([.main])
    snapshot.appendItems([.wallets, .notifications, .settings], toSection: .main)
    return snapshot
  }
}

// MARK:- Cell Registration
private extension WalletSidebarViewController {
  
  private var cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, Option> {
    return UICollectionView.CellRegistration<UICollectionViewListCell, Option> { cell, indexPath, formRow in
      // Populate the cell with our item description.
      var contentConfiguration = cell.defaultContentConfiguration()
      contentConfiguration.text = formRow.title
      contentConfiguration.image = formRow.image
      cell.contentConfiguration = contentConfiguration
    }
  }
  
}

private extension WalletSidebarViewController.Option {
  var title: String? {
    switch self {
    case .wallets:
      return NSLocalizedString("WalletSidebarViewController.Row.wallets.description", comment: "")
    case .notifications:
      return NSLocalizedString("WalletSidebarViewController.Row.notifications.description", comment: "")
    case .settings:
      return NSLocalizedString("WalletSidebarViewController.Row.settings.description", comment: "")
    }
  }
  
  var image: UIImage? {
    switch self {
    case .wallets:
      return UIImage(systemName: "creditcard")
    case .notifications:
      return UIImage(systemName: "exclamationmark.triangle")
    case .settings:
      return UIImage(systemName: "gear")
    }
  }

}
