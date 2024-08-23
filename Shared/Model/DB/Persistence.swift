//
//  Persistence.swift
//  St Jude
//
//  Created by David Stephens on 20/08/2022.
//

import Foundation
import GRDB

extension AppDatabase {
    /// The database for the application
    static let shared = makeShared()
    
    private static func makeShared() -> AppDatabase {
        do {
            // Create a folder, in the shared container, for storing the SQLite database, as well as
            // the various temporary files created during normal database
            // operations (https://sqlite.org/tempfiles.html).
            let fileManager = FileManager()
            guard let folderURL = fileManager
                .containerURL(forSecurityApplicationGroupIdentifier: "group.dev.snailedit.stjude")?
                .appendingPathComponent("database", isDirectory: true) else {
                fatalError("Unable to get container for 'group.dev.snailedit.stjude'")
            }
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
            
            // Connect to a database on disk
            // See https://github.com/groue/GRDB.swift/blob/master/README.md#database-connections
            let dbURL = folderURL.appendingPathComponent("db.2024.sqlite")
            var config = Configuration()
            #if DEBUG
            // Protect sensitive information by enabling verbose debugging in DEBUG builds only
            config.publicStatementArguments = true
            #endif
            config.prepareDatabase { db in
                db.trace { event in
#if                 DEBUG
                    sqlLogger.trace("\(event)")
#endif
                    // Access to detailed profiling information
                    if case let .profile(statement, duration) = event, duration > 0.5 {
                        sqlLogger.warning("Slow query: \(statement.sql)")
                    }
                }
            }
            let dbPool = try DatabasePool(path: dbURL.path, configuration: config)
            
            // Create the AppDatabase
            let appDatabase = try AppDatabase(dbPool)
            
            return appDatabase
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            //
            // Typical reasons for an error here include:
            // * The parent directory cannot be created, or disallows writing.
            // * The database is not accessible, due to permissions or data protection when the device is locked.
            // * The device is out of space.
            // * The database could not be migrated to its latest schema version.
            // Check the error message to determine what the actual problem was.
            fatalError("Unresolved error \(error)")
        }
    }
}
