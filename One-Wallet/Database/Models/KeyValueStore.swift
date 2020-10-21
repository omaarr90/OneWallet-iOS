//
//  KeyValueStore.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 05/03/1442 AH.
//

import Foundation
import GRDB

public class KeyValueStore {
  
  
  static let dataStoreCollection = "keyvalue"
  static let tableName = "keyvalue"
  
  static let collectionColumn = SDSColumnMetadata(columnName: "collection", columnType: .unicodeString, isOptional: false)
  static let keyColumn = SDSColumnMetadata(columnName: "key", columnType: .unicodeString, isOptional: false)
  static let valueColumn = SDSColumnMetadata(columnName: "value", columnType: .blob, isOptional: false)
  // TODO: For now, store all key-value in a single table.
  public static let table = SDSTableMetadata(collection: KeyValueStore.dataStoreCollection,
                                             tableName: KeyValueStore.tableName,
                                             columns: [
                                                collectionColumn,
                                                keyColumn,
                                                valueColumn
                                             ])
  
  // By default, all reads/writes use this collection.
  public let collection: String
  
  public init(collection: String) {
    // TODO: Verify that collection is a valid table name _OR_ convert to valid name.
    self.collection = collection
  }
  
  public class func key(int: Int) -> String {
    return NSNumber(value: int).stringValue
  }
  
  public func hasValue(forKey key: String, database: Database) -> Bool {
    do {
      let count = try UInt.fetchOne(database,
                                    sql: """
                    SELECT
                    COUNT(*)
                    FROM \(KeyValueStore.table.tableName)
                    WHERE \(KeyValueStore.keyColumn.columnName) = ?
                    AND \(KeyValueStore.collectionColumn.columnName) == ?
                    """,
                                    arguments: [key, collection]) ?? 0
      return count > 0
    } catch {
      Logger.debug("error: \(error)")
      return false
    }
  }
  
}

// MARK: - Data Access

public extension KeyValueStore {
  // MARK: - String
  func getString(_ key: String, database: Database) -> String? {
    return read(key, database: database)
  }
  
  func setString(_ value: String?, key: String, database: Database) {
    guard let value = value else {
      write(nil, forKey: key, database: database)
      return
    }
    write(value as NSString, forKey: key, database: database)
  }
  
  // MARK: - Date
  
  func getDate(_ key: String, database: Database) -> Date? {
    // Our legacy methods sometimes stored dates as NSNumber and
    // sometimes as NSDate, so we are permissive when decoding.
    guard let object: NSObject = read(key, database: database) else {
      return nil
    }
    if let date = object as? Date {
      return date
    }
    guard let epochInterval = object as? NSNumber else {
      assertionFailure("Could not decode value: \(type(of: object)).")
      return nil
    }
    return Date(timeIntervalSince1970: epochInterval.doubleValue)
  }
  
  func setDate(_ value: Date, key: String, database: Database) {
    let epochInterval = NSNumber(value: value.timeIntervalSince1970)
    setObject(epochInterval, key: key, database: database)
  }
  
  // MARK: - Bool
  
  func getBool(_ key: String, database: Database) -> Bool? {
    guard let number: NSNumber = read(key, database: database) else {
      return nil
    }
    return number.boolValue
  }
  
  func getBool(_ key: String, defaultValue: Bool, database: Database) -> Bool {
    return getBool(key, database: database) ?? defaultValue
  }
  
  func setBool(_ value: Bool, key: String, database: Database) {
    write(NSNumber(booleanLiteral: value), forKey: key, database: database)
  }
  
  // MARK: - UInt
  
  func getUInt(_ key: String, database: Database) -> UInt? {
    guard let number: NSNumber = read(key, database: database) else {
      return nil
    }
    return number.uintValue
  }
  
  // TODO: Handle numerics more generally.
  func getUInt(_ key: String, defaultValue: UInt, database: Database) -> UInt {
    return getUInt(key, database: database) ?? defaultValue
  }
  
  func setUInt(_ value: UInt, key: String, database: Database) {
    write(NSNumber(value: value), forKey: key, database: database)
  }
  
  // MARK: - Data
  
  func getData(_ key: String, database: Database) -> Data? {
    return readData(key, database: database)
  }
  
  func setData(_ value: Data?, key: String, database: Database) {
    writeData(value, forKey: key, database: database)
  }
  
  // MARK: - Numeric
  
  func getNSNumber(_ key: String, database: Database) -> NSNumber? {
    let number: NSNumber? = read(key, database: database)
    return number
  }
  
  // MARK: - Int
  
  func getInt(_ key: String, database: Database) -> Int? {
    guard let number: NSNumber = read(key, database: database) else {
      return nil
    }
    return number.intValue
  }
  
  func getInt(_ key: String, defaultValue: Int, database: Database) -> Int {
    return getInt(key, database: database) ?? defaultValue
  }
  
  func setInt(_ value: Int, key: String, database: Database) {
    setObject(NSNumber(value: value), key: key, database: database)
  }
  
  // MARK: - UInt32
  
  func getUInt32(_ key: String, database: Database) -> UInt32? {
    guard let number: NSNumber = read(key, database: database) else {
      return nil
    }
    return number.uint32Value
  }
  
  func getUInt32(_ key: String, defaultValue: UInt32, database: Database) -> UInt32 {
    return getUInt32(key, database: database) ?? defaultValue
  }
  
  func setUInt32(_ value: UInt32, key: String, database: Database) {
    setObject(NSNumber(value: value), key: key, database: database)
  }
  
  // MARK: - UInt64
  
  func getUInt64(_ key: String, database: Database) -> UInt64? {
    guard let number: NSNumber = read(key, database: database) else {
      return nil
    }
    return number.uint64Value
  }
  
  func getUInt64(_ key: String, defaultValue: UInt64, database: Database) -> UInt64 {
    return getUInt64(key, database: database) ?? defaultValue
  }
  
  func setUInt64(_ value: UInt64, key: String, database: Database) {
    setObject(NSNumber(value: value), key: key, database: database)
  }
  
  // MARK: - Double
  
  func getDouble(_ key: String, database: Database) -> Double? {
    guard let number: NSNumber = read(key, database: database) else {
      return nil
    }
    return number.doubleValue
  }
  
  func getDouble(_ key: String, defaultValue: Double, database: Database) -> Double {
    return getDouble(key, database: database) ?? defaultValue
  }
  
  func setDouble(_ value: Double, key: String, database: Database) {
    setObject(NSNumber(value: value), key: key, database: database)
  }
  
  // MARK: - Object
  
  func getObject(forKey key: String, database: Database) -> Any? {
    return read(key, database: database)
  }
  
  func setObject(_ anyValue: Any?, key: String, database: Database) {
    guard let anyValue = anyValue else {
      write(nil, forKey: key, database: database)
      return
    }
    guard let codingValue = anyValue as? NSCoding else {
      assertionFailure("Invalid value.")
      write(nil, forKey: key, database: database)
      return
    }
    write(codingValue, forKey: key, database: database)
  }
  
  func removeValue(forKey key: String, database: Database) {
    write(nil, forKey: key, database: database)
  }
  
  func removeValues(forKeys keys: [String], database: Database) {
    for key in keys {
      write(nil, forKey: key, database: database)
    }
  }
  
  func removeAll(database: Database) {
      let sql = """
                DELETE
                FROM \(KeyValueStore.table.tableName)
                WHERE \(KeyValueStore.collectionColumn.columnName) == ?
            """
    do {
      let statement = try database.cachedUpdateStatement(sql: sql)
      // TODO: We could use setArgumentsWithValidation for more safety.
      statement.setUncheckedArguments([collection])
      try statement.execute()
    } catch {
      fatalError("Error: \(error)")
    }
  }
  
  func enumerateKeysAndObjects(database: Database, block: @escaping (String, Any, UnsafeMutablePointer<ObjCBool>) -> Void) {
      var stop: ObjCBool = false
      // PERF - we could enumerate with a single query rather than
      // fetching keys then fetching objects one by one. In practice
      // the collections that use this are pretty small.
      for key in allKeys(database: database) {
        guard !stop.boolValue else {
          return
        }
        guard let value: Any = read(key, database: database) else {
          assertionFailure("value was unexpectedly nil")
          continue
        }
        block(key, value, &stop)
      }
  }
  
  func enumerateKeys(database: Database, block: @escaping (String, UnsafeMutablePointer<ObjCBool>) -> Void) {
      var stop: ObjCBool = false
      for key in allKeys(database: database) {
        guard !stop.boolValue else {
          return
        }
        block(key, &stop)
      }
  }
  
  func allValues(database: Database) -> [Any] {
    return allKeys(database: database).map { key in
      return self.read(key, database: database)
    }
  }
  
  func allDataValues(database: Database) -> [Data] {
    return allKeys(database: database).compactMap { key in
      return self.getData(key, database: database)
    }
  }
  
  func anyDataValue(database: Database) -> Data? {
    let keys = allKeys(database: database).shuffled()
    guard let firstKey = keys.first else {
      return nil
    }
    guard let data = self.getData(firstKey, database: database) else {
      assertionFailure("Missing data for key: \(firstKey)")
      return nil
    }
    return data
  }
  
  func numberOfKeys(database: Database) -> UInt {
      let sql = """
            SELECT COUNT(*)
            FROM \(KeyValueStore.table.tableName)
            WHERE \(KeyValueStore.collectionColumn.columnName) == ?
            """
      do {
        guard let numberOfKeys = try UInt.fetchOne(database,
                                                   sql: sql,
                                                   arguments: [collection]) else {
          fatalError("numberOfKeys was unexpectedly nil")
        }
        return numberOfKeys
      } catch {
        fatalError("error: \(error)")
      }
  }

}

// MARK: -
public extension KeyValueStore {
  func setCodable<T: Encodable>(_ value: T, key: String, database: Database) throws {
    do {
      let data = try JSONEncoder().encode(value)
      setData(data, key: key, database: database)
    } catch {
      assertionFailure("Failed to encode: \(error).")
      throw error
    }
  }
  
  func getCodableValue<T: Decodable>(forKey key: String, database: Database) throws -> T? {
    guard let data = getData(key, database: database) else {
      return nil
    }
    do {
      return try JSONDecoder().decode(T.self, from: data)
    } catch {
      assertionFailure("Failed to decode: \(error).")
      throw error
    }
  }
  
  func allCodableValues<T: Decodable>(database: Database) throws -> [T] {
    var result = [T]()
    for data in allDataValues(database: database) {
      do {
        result.append(try JSONDecoder().decode(T.self, from: data))
      } catch {
        assertionFailure("Failed to decode: \(error).")
        throw error
      }
    }
    return result
  }

}

// MARK: - Internal Methods
private extension KeyValueStore {
  func read<T>(_ key: String, database: Database) -> T? {
    guard let rawObject = readRawObject(key, database: database) else {
      return nil
    }
    guard let object = rawObject as? T else {
      assertionFailure("Value for key: \(key) has unexpected type: \(type(of: rawObject)).")
      return nil
    }
    return object
  }
  
  func readRawObject(_ key: String, database: Database) -> Any? {
    guard let encoded = readData(key, database: database) else {
      return nil
    }
    
    do {
      guard let rawObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(encoded) else {
        assertionFailure("Could not decode value.")
        return nil
      }
      return rawObject
    } catch {
      assertionFailure("Decode failed.")
      return nil
    }
  }
  
  func readData(_ key: String, database: Database) -> Data? {
    let collection = self.collection
    return KeyValueStore.readData(database: database, key: key, collection: collection)
  }
  
  class func readData(database: Database, key: String, collection: String) -> Data? {
    do {
      return try Data.fetchOne(database,
                               sql: "SELECT \(self.valueColumn.columnName) FROM \(self.table.tableName) WHERE \(self.keyColumn.columnName) = ? AND \(collectionColumn.columnName) == ?",
                               arguments: [key, collection])
    } catch {
      assertionFailure("error: \(error)")
      return nil
    }
  }
  
  // TODO: Codable? NSCoding? Other serialization?
  func write(_ value: NSCoding?, forKey key: String, database: Database) {
    if let value = value {
      let encoded = NSKeyedArchiver.archivedData(withRootObject: value)
      writeData(encoded, forKey: key, database: database)
    } else {
      writeData(nil, forKey: key, database: database)
    }
  }
  
  func writeData(_ data: Data?, forKey key: String, database: Database) {
    
    let collection = self.collection
    do {
      try KeyValueStore.write(database: database, key: key, collection: collection, encoded: data)
    } catch {
      assertionFailure("error: \(error)")
    }
  }
  
  class func write(database: Database, key: String, collection: String, encoded: Data?) throws {
    if let encoded = encoded {
      // See: https://www.sqlite.org/lang_UPSERT.html
      let sql = """
                INSERT INTO \(table.tableName) (
                    \(keyColumn.columnName),
                    \(collectionColumn.columnName),
                    \(valueColumn.columnName)
                ) VALUES (?, ?, ?)
                ON CONFLICT (
                    \(keyColumn.columnName),
                    \(collectionColumn.columnName)
                ) DO UPDATE
                SET \(valueColumn.columnName) = ?
            """
      try update(database: database, sql: sql, arguments: [ key, collection, encoded, encoded ])
    } else {
      // Setting to nil is a delete.
      let sql = "DELETE FROM \(table.tableName) WHERE \(keyColumn.columnName) == ? AND \(collectionColumn.columnName) == ?"
      try update(database: database, sql: sql, arguments: [ key, collection ])
    }
  }
  
  class func update(database: Database,
                            sql: String,
                            arguments: [DatabaseValueConvertible]) throws {
    
    let statement = try database.cachedUpdateStatement(sql: sql)
    guard let statementArguments = StatementArguments(arguments) else {
      assertionFailure("Could not convert values.")
      return
    }
    // TODO: We could use setArgumentsWithValidation for more safety.
    statement.setUncheckedArguments(statementArguments)
    try statement.execute()
  }
  
  func allKeys(database: Database) -> [String] {
    let sql = """
        SELECT \(KeyValueStore.keyColumn.columnName)
        FROM \(KeyValueStore.table.tableName)
        WHERE \(KeyValueStore.collectionColumn.columnName) == ?
        """
    return try! String.fetchAll(database,
                                sql: sql,
                                arguments: [collection])
  }
  

}
