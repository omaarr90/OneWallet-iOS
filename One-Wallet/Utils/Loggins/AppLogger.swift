//
//  AppLogger.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 18/02/1442 AH.
//

import Foundation

import Foundation
import SwiftyBeaver

// swiftlint:disable:next identifier_name
let Logger = AppLogger.shared.log

class AppLogger {
  static let shared = AppLogger()
  let log: SwiftyBeaver.Type
  init() {
    log = SwiftyBeaver.self
    log.addDestination(ConsoleDestination())
  }
}
