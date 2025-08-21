//
//  Loggers.swift
//  Loggers
//
//  Created by David on 22/08/2021.
//

import Foundation
import os.log

private var subsystem = Bundle.main.bundleIdentifier!

let dataLog = OSLog(subsystem: subsystem, category: "Data")
let dataLogger = Logger(dataLog)
let appLog = OSLog(subsystem: subsystem, category: "App")
let appLogger = Logger(appLog)
let apiLog = OSLog(subsystem: subsystem, category: "API")
let apiLogger = Logger(apiLog)
let refreshLog = OSLog(subsystem: subsystem, category: "Refresh")
let refreshLogger = Logger(dataLog)
let sqlLog = OSLog(subsystem: subsystem, category: "SQL")
let sqlLogger = Logger(sqlLog)
