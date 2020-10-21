import Foundation
import GRDB

struct GRDBStorage {
  
  let pool: DatabasePool
    
  private let dbURL: URL
  private let poolConfiguration: Configuration
  
  private static let maxBusyTimeoutMs = 50
  
  init(dbURL: URL) throws {
    self.dbURL = dbURL
    
    poolConfiguration = Self.buildConfiguration()
    
    pool = try DatabasePool(path: dbURL.path, configuration: poolConfiguration)
    Logger.debug("dbURL: \(dbURL)")
        
//    OWSFileSystem.protectFileOrFolder(atPath: dbURL.path)
  }
  
  private static func buildConfiguration() -> Configuration {
    var configuration = Configuration()
    configuration.readonly = false
    configuration.foreignKeysEnabled = true // Default is already true

    // Useful when your app opens multiple databases
    configuration.label = ("GRDB Storage")
    configuration.maximumReaderCount = 10   // The default is 5
    configuration.busyMode = .callback({ (retryCount: Int) -> Bool in
      // sleep N milliseconds
      let millis = 25
      usleep(useconds_t(millis * 1000))
      Logger.verbose("retryCount: \(retryCount)")
      let accumulatedWaitMs = millis * (retryCount + 1)
      if accumulatedWaitMs > 0, (accumulatedWaitMs % 250) == 0 {
        Logger.warning("Database busy for \(accumulatedWaitMs)ms")
      }
      
      return true
    })
//    configuration.prepareDatabase = { (db: Database) in
//      let keyspec = try keyspec.fetchString()
//      try db.execute(sql: "PRAGMA key = \"\(keyspec)\"")
//      try db.execute(sql: "PRAGMA cipher_plaintext_header_size = 32")
//    }
    configuration.defaultTransactionKind = .immediate
    configuration.allowsUnsafeTransactions = true
    return configuration
  }
}
