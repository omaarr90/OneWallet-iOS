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
  
  var dataSource: UICollectionViewDiffableDataSource<Section, Contact>! = nil
  
  // MARK:- private iVars
  private lazy var viewModel: ContactsViewModel = {
    let repo = MockContactsRepo()
    return ContactsViewModel(contactsRepo: repo)
  }()
  
  private var tokens = Set<AnyCancellable>()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Contacts"
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
  
  func responseReceived(contacts: [Contact]) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Contact>()
    snapshot.appendSections([.contacts])
    snapshot.appendItems(contacts, toSection: .contacts)
    dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
  }
}

// MARK:- DataSource
private extension ContactsViewController {
  func configureObservers() {
    viewModel.isLoading
      .sink { [weak self] isLoading in
        self?.isLoadingUpdated(isLoading: isLoading)
      }.store(in: &tokens)
    
    viewModel.error
      .sink { [weak self] error in
        guard let error = error else { return }
        self?.errorReceived(error: error)
      }.store(in: &tokens)
    
    viewModel.response
      .sink { [weak self] response in
        guard let response = response else { return }
        self?.responseReceived(contacts: response)
      }.store(in: &tokens)
  }
}

// MARK:- DataSource
private extension ContactsViewController {
  func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource<Section, Contact>(collectionView: collectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, item: Contact) -> UICollectionViewCell? in
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
    let snapshot = initialSnapshot()
    dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
  }
  
  func initialSnapshot() -> NSDiffableDataSourceSnapshot<Section, Contact> {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Contact>()
    snapshot.appendSections([.contacts])
    snapshot.appendItems([], toSection: .contacts)
    return snapshot
  }
}

// MARK:- Cell Registration
private extension ContactsViewController {
  
  private var contactCellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, Contact> {
    return UICollectionView.CellRegistration<UICollectionViewListCell, Contact> { cell, indexPath, contact in
      // Populate the cell with our item description.
      var contentConfiguration = cell.defaultContentConfiguration()
      contentConfiguration.text = contact.name
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
