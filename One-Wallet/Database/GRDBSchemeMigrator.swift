//
//  GRDBSchemeMigrator.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 05/03/1442 AH.
//

import Foundation
import GRDB

class GRDBSchemaMigrator {
  
  private var grdbStorage: GRDBStorage = GRDBManager.shared.grdbStorage
  
  func runSchemaMigrations() {
    if hasCreatedInitialSchema {
      Logger.info("Using incrementalMigrator.")
      try! incrementalMigrator.migrate(grdbStorage.pool)
    } else {
      Logger.info("Using newUserMigrator.")
      try! newUserMigrator.migrate(grdbStorage.pool)
    }
    Logger.info("Migrations complete.")
    
//        SSKPreferences.markGRDBSchemaAsLatest()
  }
  
  private var hasCreatedInitialSchema: Bool {
    // HACK: GRDB doesn't create the grdb_migrations table until running a migration.
    // So we can't cleanly check which migrations have run for new users until creating this
    // table ourselves.
    try! grdbStorage.pool.write {  database in
      try! self.fixit_setupMigrations(database)
    }
    
    let appliedMigrations = try! grdbStorage.pool.read(incrementalMigrator.appliedMigrations)
    Logger.info("appliedMigrations: \(appliedMigrations).")
    return appliedMigrations.contains(MigrationId.createInitialSchema.rawValue)
  }
  
  private func fixit_setupMigrations(_ db: Database) throws {
    try db.execute(sql: "CREATE TABLE IF NOT EXISTS grdb_migrations (identifier TEXT NOT NULL PRIMARY KEY)")
  }
  
  // MARK: -
  
  private enum MigrationId: String, CaseIterable {
    case createInitialSchema
    // NOTE: Every time we add a migration id, consider
    // incrementing grdbSchemaVersionLatest.
    // We only need to do this for breaking changes.
    
    // MARK: Data Migrations
    //
    // Any migration which leverages SDSModel serialization must occur *after* changes to the
    // database schema complete.
    //
    // Otherwise, for example, consider we have these two pending migrations:
    //  - Migration 1: resaves all instances of Foo (Foo is some SDSModel)
    //  - Migration 2: adds a column "new_column" to the "model_Foo" table
    //
    // Migration 1 will fail, because the generated serialization logic for Foo expects
    // "new_column" to already exist before Migration 2 has even run.
    //
    // The solution is to always split logic that leverages SDSModel serialization into a
    // separate migration, and ensure it runs *after* any schema migrations. That is, new schema
    // migrations must be inserted *before* any of these Data Migrations.
  }
  
  static let grdbSchemaVersionDefault: UInt = 0
  static let grdbSchemaVersionLatest: UInt = 1
  
  // An optimization for new users, we have the first migration import the latest schema
  // and mark any other migrations as "already run".
  private lazy var newUserMigrator: DatabaseMigrator = {
    var migrator = DatabaseMigrator()
    migrator.registerMigration(MigrationId.createInitialSchema.rawValue) { db in
      Logger.info("importing latest schema")
      guard let sqlFile = Bundle(for: GRDBSchemaMigrator.self).url(forResource: "schema", withExtension: "sql") else {
        fatalError("sqlFile was unexpectedly nil")
      }
      let sql = try String(contentsOf: sqlFile)
      try db.execute(sql: sql)
    }
    
    // After importing the initial schema, we want to skip the remaining incremental migrations
    // so we register each migration id with a no-op implementation.
    for migrationId in (MigrationId.allCases.filter { $0 != .createInitialSchema }) {
      migrator.registerMigration(migrationId.rawValue) { _ in
        Logger.info("skipping migration: \(migrationId) for new user.")
        // no-op
      }
    }
    
    return migrator
  }()
  
  class DatabaseMigratorWrapper {
    var migrator = DatabaseMigrator()
    
    func registerMigration(_ identifier: String, migrate: @escaping (Database) throws -> Void) {
      migrator.registerMigration(identifier) {  (database: Database) throws in
        Logger.info("Running migration: \(identifier)")
        try migrate(database)
      }
    }
  }
  
  // Used by existing users to incrementally update from their existing schema
  // to the latest.
  private lazy var incrementalMigrator: DatabaseMigrator = {
    var migratorWrapper = DatabaseMigratorWrapper()
    
    registerSchemaMigrations(migrator: migratorWrapper)
    
    // Data Migrations must run *after* schema migrations
    registerDataMigrations(migrator: migratorWrapper)
    
    return migratorWrapper.migrator
  }()
  
  private func registerSchemaMigrations(migrator: DatabaseMigratorWrapper) {
    
    // The migration blocks should never throw. If we introduce a crashing
    // migration, we want the crash logs reflect where it occurred.
    
    migrator.registerMigration(MigrationId.createInitialSchema.rawValue) { _ in
      fatalError("This migration should have already been run by the last YapDB migration.")
    }
    
    // MARK: - Schema Migration Insertion Point
  }
  
  func registerDataMigrations(migrator: DatabaseMigratorWrapper) {
    
    // The migration blocks should never throw. If we introduce a crashing
    // migration, we want the crash logs reflect where it occurred.
  }
  
}
