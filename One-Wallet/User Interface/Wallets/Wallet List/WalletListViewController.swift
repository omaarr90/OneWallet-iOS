//
//  WalletListViewController.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 10/03/1442 AH.
//

import UIKit
import Combine

protocol WalletListViewControllerDelegate: class {
  func walletListViewController(_ walletListViewController: WalletListViewController, didSelectWallet wallet: Wallet)
}

class WalletListViewController: BaseCollectionViewController {
  
  enum Purpose {
    case compact
    case primary
  }
  
  // MARK:- CollectionView iVars
  enum Section: Int {
    case wallets
  }
  
  
  var dataSource: UICollectionViewDiffableDataSource<Section, Wallet>! = nil
  
  // MARK:- private iVars
  private lazy var viewModel: WalletListViewModel = {
    return containersProvider.viewModelProvider.walletListViewModel
  }()
  private var tokens = Set<AnyCancellable>()
  weak var delegate: WalletListViewControllerDelegate?

  var purpose: Purpose = .compact
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = NSLocalizedString("WalletSidebarViewController.Row.wallets.description", comment: "")
    configureNavigationItem()
    configureDataSource()
    configureObservers()
  }
  
  private func configureNavigationItem() {
    let settingsItem = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                       landscapeImagePhone: UIImage(systemName: "gear"),
                                       style: .plain,
                                       target: self,
                                       action: #selector(settingsItemTapped(_:)))
    self.navigationItem.rightBarButtonItems = [settingsItem]
  }
  
  override func generateLayout() -> UICollectionViewLayout {
    var listConfiguration = UICollectionLayoutListConfiguration(appearance: purpose.appearnce)
    listConfiguration.showsSeparators = true
    let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
    return layout
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
  func configureObservers() {
    viewModel.wallets
      .sink { wallets in
        self.updateSnapShot(with: wallets, animatingDifferences: true)
      }
      .store(in: &tokens)
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
        return collectionView.dequeueConfiguredReusableCell(using: self.walletCellRegistration, for: indexPath, item: item)
      }
    }
    // load our initial data
    self.updateSnapShot(with: [], animatingDifferences: false)
  }
  
  func updateSnapShot(with wallets: [Wallet], animatingDifferences: Bool) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Wallet>()
    snapshot.appendSections([.wallets])
    snapshot.appendItems(wallets, toSection: .wallets)
    dataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: nil)
  }
}

// MARK:- Cell Registration
private extension WalletListViewController {
  
  private var walletCellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, Wallet> {
    return UICollectionView.CellRegistration<UICollectionViewListCell, Wallet> { cell, indexPath, wallet in
      // Populate the cell with our item description.
      var contentConfiguration = cell.defaultContentConfiguration()
      contentConfiguration.text = wallet.name
      cell.contentConfiguration = contentConfiguration
    }
  }
  
}

// MARK:- CollectionView Delegate
extension WalletListViewController {
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if self.purpose.clearsSelection {
      collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    guard let wallet = self.dataSource.itemIdentifier(for: indexPath) else {
      assertionFailure("Couldn't get wallet from index path")
      return
    }
    
    self.delegate?.walletListViewController(self, didSelectWallet: wallet)
  }
}

private extension WalletListViewController.Purpose {
  var appearnce: UICollectionLayoutListConfiguration.Appearance {
    switch self {
    case .compact:
      return .insetGrouped
    case .primary:
      return .sidebar
    }
  }
  
  var clearsSelection: Bool {
    switch self {
    case .compact:
      return true
    case .primary:
      return false
    }
  }
}
