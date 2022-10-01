//
//  DB.swift
//  St Jude
//
//  Created by David Stephens on 20/08/2022.
//

import Foundation
import GRDB

final class AppDatabase {
    /// Creates an `AppDatabase`, and make sure the database schema is ready.
    init(_ dbWriter: DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try migrator.migrate(dbWriter)
    }
    
    /// Provides access to the database.
    ///
    /// Application can use a `DatabasePool`, and tests can use a fast
    /// in-memory `DatabaseQueue`.
    ///
    /// See <https://github.com/groue/GRDB.swift/blob/master/README.md#database-connections>
    private let dbWriter: DatabaseWriter
    
    /// The DatabaseMigrator that defines the database schema.
    ///
    /// See <https://github.com/groue/GRDB.swift/blob/master/Documentation/Migrations.md>
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        #if DEBUG
        // Speed up development by nuking the database when migrations change
        // See https://github.com/groue/GRDB.swift/blob/master/Documentation/Migrations.md#the-erasedatabaseonschemachange-option
        migrator.eraseDatabaseOnSchemaChange = true
        #endif
        
        migrator.registerMigration("createInitialTables") { db in
            // Create a table
            // See https://github.com/groue/GRDB.swift#create-tables
            
            try db.create(table: "fundraisingEvent") { t in
                t.column("id", .blob).primaryKey()
                t.column("name", .text).notNull()
                t.column("slug", .text).notNull()
                t.column("amountRaisedCurrency", .text).notNull()
                t.column("amountRaisedValue", .text)
                t.column("colors", .text).notNull()
                t.column("description", .text)
                t.column("goalCurrency", .text).notNull()
                t.column("goalValue", .text).notNull()
                t.column("causePublicId", .numeric).notNull().unique()
                t.column("causeName", .text).notNull()
                t.column("causeSlug", .text).notNull()
                t.uniqueKey(["slug", "causeSlug"])
            }
            
            try db.create(table: "campaign") { t in
                t.column("id", .blob).primaryKey()
                t.column("name", .text).notNull()
                t.column("slug", .text).notNull()
                t.column("avatar", .text)
                t.column("status", .text)
                t.column("description", .blob)
                t.column("goalCurrency", .text).notNull()
                t.column("goalValue", .text).notNull()
                t.column("totalRaisedCurrency", .text).notNull()
                t.column("totalRaisedValue", .text).notNull()
                t.column("username", .text).notNull()
                t.column("userSlug", .text).notNull()
                t.column("fundraisingEventId", .blob).notNull().references("fundraisingEvent")
                t.uniqueKey(["slug", "userSlug"])
            }
            
        }
        
        migrator.registerMigration("createMilestoneAndRewardTables") { db in
            
            try db.create(table: "milestone") { t in
                t.column("id", .integer).primaryKey()
                t.column("name", .text).notNull()
                t.column("amountCurrency", .text).notNull()
                t.column("amountValue", .double).notNull()
                t.column("campaignId", .blob).notNull().references("campaign")
            }
            
            try db.create(table: "reward") { t in
                t.column("id", .blob).primaryKey()
                t.column("name", .text).notNull()
                t.column("description", .blob).notNull()
                t.column("amountCurrency", .text).notNull()
                t.column("amountValue", .double).notNull()
                t.column("imageSrc", .text)
                t.column("campaignId", .blob).notNull().references("campaign")
            }
            
            try db.alter(table: "campaign") { t in
                t.add(column: "isStarred", .boolean).defaults(to: false)
            }
            
        }
        
        migrator.registerMigration("addNumericValues") { db in
            try db.alter(table: "campaign") { t in
                t.add(column: "goalNumericalValue", .double)
                t.add(column: "totalRaisedNumericalValue", .double)
            }
        }
        
        return migrator
    }
}

extension AppDatabase {
    func saveFundraisingEvent(_ event: FundraisingEvent) async throws -> FundraisingEvent {
        try await dbWriter.write { db in
            try event.saved(db)
        }
    }
    
    /**
     If the event has any difference from the other event, executes an
     UPDATE statement so that those differences and only those difference are
     saved in the database.
     - parameter newEvent: The latest version of the event.
     - parameter oldEvent: The event to compare against..
     - returns: Whether the event had changes.
     - throws: A DatabaseError is thrown whenever an SQLite error occurs.
     PersistenceError.recordNotFound is thrown if the primary key does not
     match any row in the database and record could not be updated.
     */
    @discardableResult
    func updateFundraisingEvent(_ newEvent: FundraisingEvent, changesFrom oldEvent: FundraisingEvent) async throws -> Bool {
        try await dbWriter.write { db in
            try newEvent.updateChanges(db, from: oldEvent)
        }
    }
    
    private func fetchFundraisingEvent(using db: Database, with slug: String, forCause causeSlug: String) throws -> FundraisingEvent? {
        try FundraisingEvent.all().filter(slug: slug, causeSlug: causeSlug).fetchOne(db)
    }
    
    func fetchFundraisingEvent(with slug: String, forCause causeSlug: String) async throws -> FundraisingEvent? {
        try await dbWriter.read { db in
            try self.fetchFundraisingEvent(using: db, with: slug, forCause: causeSlug)
        }
    }
    
    private func fetchRelayFundraisingEvent(using db: Database) throws -> FundraisingEvent? {
        try fetchFundraisingEvent(using: db, with: "relay-fm-for-st-jude-2022", forCause: "st-jude-children-s-research-hospital")
    }
    
    func fetchRelayFundraisingEvent() async throws -> FundraisingEvent? {
        try await fetchFundraisingEvent(with: "relay-fm-for-st-jude-2022", forCause: "st-jude-children-s-research-hospital")
    }
    
    func fetchAllCampaigns(for event: FundraisingEvent) async throws -> [Campaign] {
        try await dbWriter.read { db in
            try event.campaigns.fetchAll(db)
        }
    }
    
    private func fetchCampaign(using db: Database, with id: UUID) throws -> Campaign? {
        try Campaign.fetchOne(db, id: id)
    }
    
    func fetchCampaign(with id: UUID) async throws -> Campaign? {
        try await dbWriter.read { db in
            try Campaign.fetchOne(db, id: id)
        }
    }
    
    func fetchRelayCampaign() async throws -> Campaign? {
        try await fetchCampaign(with: UUID(uuidString: "8a17ee82-b90a-4aba-a22f-e8cc7e8cf410")!)
    }
    
    func deleteCampaign(_ campaign: Campaign) async throws {
        try await dbWriter.write { db in
            try campaign.delete(db)
        }
    }
    
    func saveCampaign(_ campaign: Campaign) async throws -> Campaign {
        try await dbWriter.write { db in
            try campaign.saved(db)
        }
    }
    
    func saveMilestone(_ milestone: Milestone) async throws -> Milestone {
        try await dbWriter.write { db in
            try milestone.saved(db)
        }
    }
    
    func deleteMilestone(_ milestone: Milestone) async throws {
        try await dbWriter.write { db in
            try milestone.delete(db)
        }
    }
    
    func fetchSortedMilestones(for campaign: Campaign) async throws -> [Milestone] {
        try await dbWriter.read { db in
            try campaign.milestones.order(Column("amountValue").asc).fetchAll(db)
        }
    }
    
    func saveReward(_ reward: Reward) async throws -> Reward {
        try await dbWriter.write { db in
            try reward.saved(db)
        }
    }
    
    func deleteReward(_ reward: Reward) async throws {
        try await dbWriter.write { db in
            try reward.delete(db)
        }
    }
    
    func fetchSortedRewards(for campaign: Campaign) async throws -> [Reward] {
        try await dbWriter.read { db in
            try campaign.rewards.order(Column("amountValue").asc).fetchAll(db)
        }
    }
    
    /**
     If the campaign has any difference from the other campaign, executes an
     UPDATE statement so that those differences and only those difference are
     saved in the database.
     - parameter newCampaign: The latest version of the campaign.
     - parameter oldCampaign: The event to compare campaign..
     - returns: Whether the campaign had changes.
     - throws: A DatabaseError is thrown whenever an SQLite error occurs.
     PersistenceError.recordNotFound is thrown if the primary key does not
     match any row in the database and record could not be updated.
     */
    @discardableResult
    func updateCampaign(_ newCampaign: Campaign, changesFrom oldCampaign: Campaign) async throws -> Bool {
        try await dbWriter.write { db in
            try newCampaign.updateChanges(db, from: oldCampaign)
        }
    }
    
    @discardableResult
    func updateMilestone(_ newMilestone: Milestone, changesFrom oldMilestone: Milestone) async throws -> Bool {
        try await dbWriter.write { db in
            try newMilestone.updateChanges(db, from: oldMilestone)
        }
    }
    
    @discardableResult
    func updateReward(_ newReward: Reward, changesFrom oldReward: Reward) async throws -> Bool {
        try await dbWriter.write { db in
            try newReward.updateChanges(db, from: oldReward)
        }
    }
    
}

extension AppDatabase {
    func observeRelayFundraisingEventObservation() -> ValueObservation<ValueReducers.Fetch<FundraisingEvent?>> {
        ValueObservation.trackingConstantRegion { db in
            try AppDatabase.shared.fetchRelayFundraisingEvent(using: db)
        }
    }
    
    func observeCampaignObservation(for campaign: Campaign) -> ValueObservation<ValueReducers.Fetch<Campaign?>> {
        ValueObservation.trackingConstantRegion { db in
            try AppDatabase.shared.fetchCampaign(using: db, with: campaign.id)
        }
    }
}

extension AppDatabase {
    func start<T: ValueReducer>(observation: ValueObservation<T>,
                                scheduling scheduler: ValueObservationScheduler = .async(onQueue: .main),
                                onError: @escaping (Error) -> Void,
                                onChange: @escaping (T.Value) -> Void) -> DatabaseCancellable {
        observation.start(in: dbWriter, scheduling: scheduler, onError: onError, onChange: onChange)
    }
}
