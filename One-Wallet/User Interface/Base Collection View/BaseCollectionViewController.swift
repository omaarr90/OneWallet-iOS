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
    listConfiguration.showsSeparators = true
    listConfiguration.backgroundColor = .systemBackground
    let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
    return layout
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    guard self.traitCollection != previousTraitCollection else { return }
    
    if self.traitCollection.horizontalSizeClass == .regular {
      // we're in split view
      self.view.backgroundColor = .systemBlue
    } else if self.traitCollection.horizontalSizeClass == .compact {
      self.view.backgroundColor = .systemRed
    }
  }
}

// MARK:- CollectionView Layout
extension BaseCollectionViewController {
}

// MARK:- CollectionView DataSource
extension BaseCollectionViewController {
}

// MARK:- CollectionView Delegate
extension BaseCollectionViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
}
