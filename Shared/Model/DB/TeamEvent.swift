//
//  TeamEvent.swift
//  St Jude
//
//  Created by Ben Cardy on 03/08/2023.
//

import Foundation

import GRDB

/// The Campaign struct.
struct TeamEvent: Identifiable, Hashable {
    /// The campaign publicId
    var id: UUID { publicId }
    var publicId: UUID
    let name: String
    let description: String
    private let goalCurrency: String
    private let goalValue: String?
    var goal: TiltifyAmount {
        TiltifyAmount(currency: goalCurrency, value: goalValue)
    }
    let goalNumericalValue: Double?
    var goalNumerical: Double {
        goalNumericalValue ?? 0
    }
    func goalDescription(showFullCurrencySymbol: Bool) -> String {
        currencyDescription(showFullCurrencySymbol: showFullCurrencySymbol, value: goalNumerical, currency: goalCurrency)
    }
    private let totalRaisedCurrency: String
    private let totalRaisedValue: String?
    var totalRaised: TiltifyAmount {
        TiltifyAmount(currency: totalRaisedCurrency, value: totalRaisedValue)
    }
    let totalRaisedNumericalValue: Double?
    var totalRaisedNumerical: Double {
        totalRaisedNumericalValue ?? 0
    }
    func totalRaisedDescription(showFullCurrencySymbol: Bool) -> String {
        currencyDescription(showFullCurrencySymbol: showFullCurrencySymbol, value: totalRaisedNumerical, currency: totalRaisedCurrency)
    }
    
    var percentageReached: Double? {
        return calcPercentage(goal: goal.value ?? "0", total: totalRaised.value ?? "0")
    }
    
    var multiplier: Int {
        if(self.totalRaisedNumerical <= self.goalNumerical) {
            return 1
        }
        return Int(floor(self.totalRaisedNumerical/self.goalNumerical))+1
    }
    
    var percentageReachedDescription: String? {
        guard let percentageReached = percentageReached else {
            return nil
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.roundingMode = .down
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter.string(from: percentageReached as NSNumber)
    }
    
    var amountRemainingDescription: String {
        let value = max(goalNumerical - totalRaisedNumerical, 0)
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = goal.currency
        currencyFormatter.currencySymbol = "$"
        let descriptionString = currencyFormatter.string(from: value as NSNumber) ?? "\(goal.currency) 0"
        return descriptionString
    }
    
    private func currencyDescription(showFullCurrencySymbol: Bool, value: Double, currency: String) -> String {
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = currency
        
        let originalSymbol = currencyFormatter.currencySymbol
        let originalCode = currencyFormatter.currencyCode
        
        currencyFormatter.currencyCode = "USD"
        if !showFullCurrencySymbol {
            currencyFormatter.currencySymbol = "$"
        } else {
            currencyFormatter.currencySymbol = "USD"
        }
        
        let descriptionString = currencyFormatter.string(from: value as NSNumber) ?? "\(currency) 0"
        currencyFormatter.currencySymbol = originalSymbol
        currencyFormatter.currencyCode = originalCode
        
        return descriptionString
    }
    
}

extension TeamEvent: Codable, FetchableRecord, MutablePersistableRecord {
    fileprivate enum Columns {
        static let publicId = Column(CodingKeys.publicId)
        static let name = Column(CodingKeys.name)
        static let description = Column(CodingKeys.description)
        static let goalCurrency = Column(CodingKeys.goalCurrency)
        static let goalValue = Column(CodingKeys.goalValue)
        static let goalNumericalValue = Column(CodingKeys.goalNumericalValue)
        static let totalRaisedCurrency = Column(CodingKeys.totalRaisedCurrency)
        static let totalRaisedValue = Column(CodingKeys.totalRaisedValue)
        static let totalRaisedNumericalValue = Column(CodingKeys.totalRaisedNumericalValue)
    }
    
    static let milestones = hasMany(Milestone.self)
    var milestones: QueryInterfaceRequest<Milestone> {
        request(for: TeamEvent.milestones)
    }
    
    static let rewards = hasMany(Reward.self)
    var rewards: QueryInterfaceRequest<Reward> {
        request(for: TeamEvent.rewards)
    }
    
    static let polls = hasMany(Poll.self)
    var polls: QueryInterfaceRequest<Poll> {
        request(for: TeamEvent.polls)
    }
}

extension TeamEvent {
    init(from apiData: TiltifyTeamEvent) {
        self.publicId = apiData.publicId
        self.name = apiData.name
        self.totalRaisedCurrency = apiData.totalAmountRaised.currency
        self.totalRaisedValue = apiData.totalAmountRaised.value
        self.totalRaisedNumericalValue = apiData.totalAmountRaised.numericalValue
        self.description = apiData.description
        self.goalCurrency = apiData.goal.currency
        self.goalValue = apiData.goal.value
        self.goalNumericalValue = apiData.goal.numericalValue
    }
    
    init(from apiData: TiltifyResponse2025) {
        self.publicId = apiData.data.fact.id
        self.name = apiData.data.fact.name
        self.totalRaisedCurrency = apiData.data.fact.totalAmountRaised.currency
        self.totalRaisedValue = apiData.data.fact.totalAmountRaised.value
        self.totalRaisedNumericalValue = apiData.data.fact.totalAmountRaised.numericalValue
        self.description = apiData.data.fact.description
        self.goalCurrency = apiData.data.fact.goal.currency
        self.goalValue = apiData.data.fact.goal.value
        self.goalNumericalValue = apiData.data.fact.goal.numericalValue
    }
    
    init(from apiData: TiltifyFundraisingEvent) {
        self.publicId = apiData.id
        self.name = apiData.name
        self.totalRaisedCurrency = apiData.totalAmountRaised.currency
        self.totalRaisedValue = apiData.totalAmountRaised.value
        self.totalRaisedNumericalValue = apiData.totalAmountRaised.numericalValue
        self.description = apiData.description
        self.goalCurrency = apiData.goal.currency
        self.goalValue = apiData.goal.value
        self.goalNumericalValue = apiData.goal.numericalValue
    }
}

extension TeamEvent {
    func checkForPollUpdates() async {
        await self.updatePollsInDatabase(with: await TiltifyAPIClient.shared.getCampaignPolls(forId: id))
    }
    
    struct ApiPollToDbPollWrapper {
        let poll: Poll
        let options: [PollOption]
    }
    
    func updatePollsInDatabase(with apiPolls: [TiltifyCampaignPoll]) async {
        
        // Only save polls to DB when campaign is starred
        dataLogger.debug("Updating Polls for team event")
        
        var keyedApiPolls: [UUID: ApiPollToDbPollWrapper] = apiPolls.filter { $0.active }.reduce(into: [:]) { partialResult, poll in
            let pollObj = Poll(from: poll, teamEventId: self.publicId)
            
            let pollOptionsObj = poll.options.map { apiPollOption in
                return PollOption(from: apiPollOption, pollId: poll.id)
            }
            
            let objToInsert = ApiPollToDbPollWrapper(poll: pollObj, options: pollOptionsObj)
            
            partialResult.updateValue(objToInsert, forKey: poll.id)
        }
        
        do {
            let dbPolls = try await AppDatabase.shared.fetchSortedPolls(for: self)
            
            // For each poll from the database...
            for dbPoll in dbPolls {
                if let apiPollWrapper = keyedApiPolls[dbPoll.id] {
                    let apiPoll = apiPollWrapper.poll
                    // Update it from the API if it exists...
                    keyedApiPolls.removeValue(forKey: dbPoll.id)
                    dataLogger.debug("Updating Poll \(apiPoll.name)")
                    do {
                        try await AppDatabase.shared.updatePoll(apiPoll, changesFrom: dbPoll)
                    } catch {
                        dataLogger.error("Failed to update Poll: \(apiPoll.name): \(error.localizedDescription)")
                    }

                    var keyedApiPollOptions: [UUID: PollOption] = apiPollWrapper.options.reduce(into: [:]) { partial, option in
                        partial.updateValue(option, forKey: option.id)
                    }
                    
                    do {
                        for dbPollOption in try await AppDatabase.shared.fetchPollOptions(for: dbPoll) {
                            if let apiPollOption = keyedApiPollOptions[dbPollOption.id] {
                                keyedApiPollOptions.removeValue(forKey: dbPollOption.id)
                                // Update it from the API if it exists
                                try await AppDatabase.shared.updatePollOption(apiPollOption, changesFrom: dbPollOption)
                            } else {
                                // Remove it from the DB if it doesn't
                                try await AppDatabase.shared.deletePollOption(dbPollOption)
                            }
                        }
                    } catch {
                        dataLogger.error("Couldn't update or remove poll option from API: \(error.localizedDescription)")
                    }
                        
                    // Add each new poll option from the API to the DB
                    for apiPollOption in keyedApiPollOptions.values {
                        do {
                            try await AppDatabase.shared.savePollOption(apiPollOption)
                        } catch {
                            dataLogger.error("Failed to add new poll option: \(apiPollOption.name): \(error.localizedDescription)")
                        }
                    }
                } else {
                    // Remove it from the database if it doesn't...
                    dataLogger.debug("Removing Poll \(dbPoll.name)")
                    
                    // Remove all the options from the db first
                    for pollOption in try await AppDatabase.shared.fetchPollOptions(for: dbPoll) {
                        dataLogger.debug("Removing poll option: \(pollOption.name)")
                        do {
                            try await AppDatabase.shared.deletePollOption(pollOption)
                        } catch {
                            dataLogger.error("Failed to delete poll option \(pollOption.name): \(error.localizedDescription)")
                        }
                    }
                            
                    do {
                        try await AppDatabase.shared.deletePoll(dbPoll)
                    } catch {
                        dataLogger.error("Failed to delete Poll \(dbPoll.name): \(error.localizedDescription)")
                    }
                }
            }
            // For each new poll in the API, save it to the database
            for apiPollWrapper in keyedApiPolls.values {
                let apiPoll = apiPollWrapper.poll
                dataLogger.debug("Creating Poll: \(apiPoll.name)")
                do {
                    try await AppDatabase.shared.savePoll(apiPoll)
                } catch {
                    dataLogger.error("Failed to save Poll \(apiPoll.name): \(error.localizedDescription)")
                }
                
                let apiPollOptions = apiPollWrapper.options
                for apiPollOption in apiPollOptions {
                    dataLogger.debug("Creating Poll Option: \(apiPollOption.name) on Poll: \(apiPoll.name)")
                    do {
                        try await AppDatabase.shared.savePollOption(apiPollOption)
                    } catch {
                        dataLogger.error("Failed to save Poll Option \(apiPollOption.name): \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            dataLogger.debug("Failed to update Poll: \(error.localizedDescription)")
        }
        
    }
}
