//
//  HomeViewController.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 04/03/1442 AH.
//

import UIKit

class BaseViewController: UIViewController {
  
  var collectionView: UICollectionView! = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

// MARK:- CollectionView Layout
extension BaseViewController {
  
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
extension BaseViewController {
}

// MARK:- CollectionView Delegate
extension BaseViewController: UICollectionViewDelegate {}
