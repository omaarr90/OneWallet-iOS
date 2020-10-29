//
//  ContactsViewController.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 08/03/1442 AH.
//

import UIKit
import Combine

class ContactsViewController: BaseCollectionViewController {
  
  // MARK:- CollectionView iVars
  enum Section: Int {
    case contacts
  }
  
//  struct Row: Hashable {
//    let Contact
//  }
  
  var dataSource: UICollectionViewDiffableDataSource<Section, WalletUser>! = nil
  
  // MARK:- private iVars
  private lazy var viewModel: ContactsViewModel = {
    return containersProvider.viewModelProvider.contactsViewModel
  }()
  
  private var tokens = Set<AnyCancellable>()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = NSLocalizedString("WalletSidebarViewController.Row.contacts.description", comment: "")
    configureDataSource()
    configureObservers()
  }
}

// MARK:- View Controller State Management
private extension ContactsViewController {
  func isLoadingUpdated(isLoading: Bool) {
  }
  
  func errorReceived(error: Error) {
    
  }
  
  func responseReceived(contacts: [WalletUser]) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, WalletUser>()
    snapshot.appendSections([.contacts])
    snapshot.appendItems(contacts, toSection: .contacts)
    dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
  }
}

// MARK:- DataSource
private extension ContactsViewController {
  func configureObservers() {
    viewModel.users
      .sink { users in
        self.updateSnapShot(with: users, animatingDifferences: true)
      }
      .store(in: &tokens)
  }
}

// MARK:- DataSource
private extension ContactsViewController {
  func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource<Section, WalletUser>(collectionView: collectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, item: WalletUser) -> UICollectionViewCell? in
      // Return the cell.
      guard let section = Section(rawValue: indexPath.section) else {
        return nil
      }
      switch section {
      case .contacts:
        return collectionView.dequeueConfiguredReusableCell(using: self.contactCellRegistration, for: indexPath, item: item)
      }
    }
    // load our initial data
    updateSnapShot(with: [], animatingDifferences: false)
  }
  
  func updateSnapShot(with users: [WalletUser], animatingDifferences: Bool) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, WalletUser>()
    snapshot.appendSections([.contacts])
    snapshot.appendItems(users, toSection: .contacts)
    dataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: nil)
  }
}

// MARK:- Cell Registration
private extension ContactsViewController {
  
  private var contactCellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, WalletUser> {
    return UICollectionView.CellRegistration<UICollectionViewListCell, WalletUser> { cell, indexPath, contact in
      // Populate the cell with our item description.
      var contentConfiguration = cell.defaultContentConfiguration()
      contentConfiguration.text = contact.contact?.firstName
      contentConfiguration.secondaryText = contact.phoneNumber
      contentConfiguration.image = UIImage.init(systemName: "person.circle")
      contentConfiguration.imageProperties.tintColor = .label
      cell.contentConfiguration = contentConfiguration
      cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
    }
  }
}

// MARK:- CollectionView Delegate
private extension ContactsViewController {
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
  }
}
