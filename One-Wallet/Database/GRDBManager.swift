//
//  GRDBManager.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 05/03/1442 AH.
//

import Foundation
import GRDB

class GRDBManager {
  static let shared = GRDBManager()
  let grdbStorage: GRDBStorage
  
  init() {
    #warning("Protect Database File")
    do {
      let databaseURL = try FileManager.default
        .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        .appendingPathComponent("db.sqlite")
      grdbStorage = try GRDBStorage(dbURL: databaseURL)
    } catch let error {
      fatalError("unable to set up GRDBStorage with error \(error)")
    }
  }
}
