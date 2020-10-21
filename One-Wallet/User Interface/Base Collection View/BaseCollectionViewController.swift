//
//  HomeViewController.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 04/03/1442 AH.
//

import UIKit

class BaseCollectionViewController: UIViewController {
  
  var collectionView: UICollectionView! = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureCollectionView()
  }
}

// MARK:- CollectionView Layout
extension BaseCollectionViewController {
  
  func configureCollectionView() {
    let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: generateLayout())
    view.addSubview(collectionView)
    collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    collectionView.backgroundColor = .clear
    self.collectionView = collectionView
    collectionView.delegate = self
  }
  
  func generateLayout() -> UICollectionViewLayout {
    var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
    listConfiguration.showsSeparators = false
    listConfiguration.backgroundColor = .systemBackground
    let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
    return layout
  }
}

// MARK:- CollectionView DataSource
extension BaseCollectionViewController {
}

// MARK:- CollectionView Delegate
extension BaseCollectionViewController: UICollectionViewDelegate {}
