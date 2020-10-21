//
//  WalletPreferences.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 05/03/1442 AH.
//

import Foundation

public class WalletPreferences {
  
  public static let shared = WalletPreferences()
  private let store = KeyValueStore(collection: "WalletPreferences")
  private let appUserDefaults = UserDefaults.init()
  
  private let grdbSchemaVersionKey = "grdbSchemaVersion"
  var grdbSchemaVersionDefault: UInt {
    return GRDBSchemaMigrator.grdbSchemaVersionDefault
  }
  var grdbSchemaVersionLatest: UInt {
    return GRDBSchemaMigrator.grdbSchemaVersionLatest
  }

}

// MARK: - Database Schema Versions

public extension WalletPreferences {
  
  private func grdbSchemaVersion() -> UInt {
    guard let preference = appUserDefaults.object(forKey: grdbSchemaVersionKey) as? NSNumber else {
      return grdbSchemaVersionDefault
    }
    return preference.uintValue
  }
  
  func markGRDBSchemaAsLatest() {
    setGrdbSchemaVersion(grdbSchemaVersionLatest)
  }
  
  private func setGrdbSchemaVersion(_ value: UInt) {
    let lastKnownGrdbSchemaVersion = grdbSchemaVersion()
    guard value != lastKnownGrdbSchemaVersion else {
      return
    }
    guard value > lastKnownGrdbSchemaVersion else {
      assertionFailure("Reverting to earlier schema version: \(value)")
      return
    }
    Logger.info("Updating schema version: \(lastKnownGrdbSchemaVersion) -> \(value)")
    appUserDefaults.set(value, forKey: grdbSchemaVersionKey)
    appUserDefaults.synchronize()
  }
}
