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
        
        migrator.registerMigration("createInitialTables2023") { db in
            
            // New version of fundraisingEvent
            try db.create(table: "teamEvent") { t in
                t.column("publicId", .blob).primaryKey()
                t.column("name", .text).notNull()
                t.column("description", .blob).notNull()
                t.column("goalCurrency", .text).notNull()
                t.column("goalValue", .text).notNull()
                t.column("goalNumericalValue", .double).notNull()
                t.column("totalRaisedCurrency", .text).notNull()
                t.column("totalRaisedValue", .text).notNull()
                t.column("totalRaisedNumericalValue", .double).notNull()
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
                t.column("isStarred", .boolean).defaults(to: false)
                t.column("goalNumericalValue", .double)
                t.column("totalRaisedNumericalValue", .double)
                t.uniqueKey(["slug", "userSlug"])
            }
            
            try db.create(table: "milestone") { t in
                t.column("publicId", .blob).primaryKey()
                t.column("name", .text).notNull()
                t.column("amountCurrency", .text).notNull()
                t.column("amountValue", .double).notNull()
                t.column("campaignId", .blob).references("campaign")
                t.column("teamEventId", .blob).references("teamEvent")
            }
            
            try db.create(table: "reward") { t in
                t.column("publicId", .blob).primaryKey()
                t.column("name", .text).notNull()
                t.column("description", .blob).notNull()
                t.column("amountCurrency", .text).notNull()
                t.column("amountValue", .double).notNull()
                t.column("imageSrc", .text)
                t.column("campaignId", .blob).references("campaign")
                t.column("teamEventId", .blob).references("teamEvent")
            }
            
        }
        
        return migrator
    }
}

extension AppDatabase {
    
    // MARK: 2023
    
    @discardableResult
    func saveTeamEvent(_ event: TeamEvent) async throws -> TeamEvent {
        try await dbWriter.write { db in
            try event.saved(db)
        }
    }
    
    @discardableResult
    func updateTeamEvent(_ newEvent: TeamEvent, changesFrom oldEvent: TeamEvent) async throws -> Bool {
        try await dbWriter.write { db in
            try newEvent.updateChanges(db, from: oldEvent)
        }
    }
    
    private func fetchTeamEvent(using db: Database) throws -> TeamEvent? {
        try TeamEvent.all().fetchOne(db)
    }
    
    func fetchTeamEvent() throws -> TeamEvent? {
        try dbWriter.read { db in
            try self.fetchTeamEvent(using: db)
        }
    }
    
    func fetchTeamEvent() async throws -> TeamEvent? {
        try await dbWriter.read { db in
            try self.fetchTeamEvent(using: db)
        }
    }
    
    func fetchAllCampaigns() async throws -> [Campaign] {
        try await dbWriter.read { db in
            try Campaign.fetchAll(db)
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
    
    @discardableResult
    func deleteCampaign(_ campaign: Campaign) async throws -> Bool {
        try await dbWriter.write { db in
            try campaign.delete(db)
        }
    }

    @discardableResult
    func saveCampaign(_ campaign: Campaign) async throws -> Campaign {
        try await dbWriter.write { db in
            try campaign.saved(db)
        }
    }

    @discardableResult
    func saveMilestone(_ milestone: Milestone) async throws -> Milestone {
        try await dbWriter.write { db in
            try milestone.saved(db)
        }
    }
    
    @discardableResult
    func deleteMilestone(_ milestone: Milestone) async throws -> Bool {
        try await dbWriter.write { db in
            try milestone.delete(db)
        }
    }
    
    func fetchSortedMilestones(for campaign: Campaign) async throws -> [Milestone] {
        try await dbWriter.read { db in
            try campaign.milestones.order(Column("amountValue").asc).fetchAll(db)
        }
    }
    
    func fetchSortedMilestones(for teamEvent: TeamEvent) async throws -> [Milestone] {
        try await dbWriter.read { db in
            try teamEvent.milestones.order(Column("amountValue").asc).fetchAll(db)
        }
    }
    
    @discardableResult
    func saveReward(_ reward: Reward) async throws -> Reward {
        try await dbWriter.write { db in
            try reward.saved(db)
        }
    }
    
    @discardableResult
    func deleteReward(_ reward: Reward) async throws -> Bool {
        try await dbWriter.write { db in
            try reward.delete(db)
        }
    }
    
    func fetchSortedRewards(for campaign: Campaign) async throws -> [Reward] {
        try await dbWriter.read { db in
            try campaign.rewards.order(Column("amountValue").asc).fetchAll(db)
        }
    }
    
    func fetchSortedRewards(for teamEvent: TeamEvent) async throws -> [Reward] {
        try await dbWriter.read { db in
            try teamEvent.rewards.order(Column("amountValue").asc).fetchAll(db)
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
    
    // MARK: 2023
    
    func observeTeamEventObservation() -> ValueObservation<ValueReducers.Fetch<TeamEvent?>> {
        ValueObservation.trackingConstantRegion { db in
            try AppDatabase.shared.fetchTeamEvent()
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
