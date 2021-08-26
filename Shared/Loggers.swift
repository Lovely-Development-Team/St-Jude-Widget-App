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
let refreshLog = OSLog(subsystem: subsystem, category: "Refresh")
let refreshLogger = Logger(dataLog)
