//
//  Campaign.swift
//  St Jude
//
//  Created by David Stephens on 20/08/2022.
//

import Foundation
import GRDB

/// The Campaign struct.
struct Campaign: Identifiable, Hashable {
    /// The campaign publicId
    var id: UUID
    let name: String
    let slug: String
    let avatar: TiltifyAvatar?
    let status: String?
    let description: String?
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
    func totalRaisedDescription(showFullCurrencySymbol: Bool, trimDecimalPlaces: Bool = false) -> String {
        currencyDescription(showFullCurrencySymbol: showFullCurrencySymbol, value: totalRaisedNumerical, currency: totalRaisedCurrency, trimDecimalPlaces: trimDecimalPlaces)
    }
    private let username: String
    private let userSlug: String
    var user: TiltifyUser {
        TiltifyUser(username: username, slug: userSlug, avatar: avatar)
    }
    var isStarred: Bool
    
    var percentageReached: Double? {
        return calcPercentage(goal: goal.value ?? "0", total: totalRaised.value ?? "0")
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
    
    private func currencyDescription(showFullCurrencySymbol: Bool, value: Double, currency: String, trimDecimalPlaces: Bool = false) -> String {
        
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
        
        if trimDecimalPlaces && descriptionString.hasSuffix("00") {
            return String(descriptionString.dropLast(3))
        }
        
        return descriptionString
    }
    
    var title: String {
        username == "Relay" ? "Relay" : name
    }
    
    var url: URL {
        URL(string: "https://tiltify.com/@\(user.slug)/\(slug)")!
    }
    
    var directDonateURL: URL {
        URL(string: "https://donate.tiltify.com/@\(user.slug)/\(slug)")!
    }
    
    var multiplier: Int {
        return self.totalRaisedNumerical.multiplierToTwoDecimalPlaces(of: self.goalNumerical)
    }
}

extension Campaign: Codable, FetchableRecord, MutablePersistableRecord {
    fileprivate enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let slug = Column(CodingKeys.slug)
        static let avatar = Column(CodingKeys.avatar)
        static let status = Column(CodingKeys.status)
        static let description = Column(CodingKeys.description)
        static let goalCurrency = Column(CodingKeys.goalCurrency)
        static let goalValue = Column(CodingKeys.goalValue)
        static let goalNumericalValue = Column(CodingKeys.goalNumericalValue)
        static let totalRaisedCurrency = Column(CodingKeys.totalRaisedCurrency)
        static let totalRaisedValue = Column(CodingKeys.totalRaisedValue)
        static let totalRaisedNumericalValue = Column(CodingKeys.totalRaisedNumericalValue)
        static let username = Column(CodingKeys.username)
        static let userSlug = Column(CodingKeys.userSlug)
        static let isStarred = Column(CodingKeys.isStarred)
    }
    
    static let milestones = hasMany(Milestone.self)
    var milestones: QueryInterfaceRequest<Milestone> {
        request(for: Campaign.milestones)
    }
    
    static let rewards = hasMany(Reward.self)
    var rewards: QueryInterfaceRequest<Reward> {
        request(for: Campaign.rewards)
    }
}

extension Campaign {
    init(from campaign: TiltifyCauseCampaign) {
        self.id = campaign.publicId
        self.name = campaign.name
        self.slug = campaign.slug
        self.avatar = campaign.avatar ?? campaign.user.avatar
        self.status = nil
        self.description = campaign.description
        self.goalCurrency = campaign.goal.currency
        self.goalValue = campaign.goal.value
        self.goalNumericalValue = campaign.goal.numericalValue
        self.totalRaisedCurrency = campaign.totalAmountRaised.currency
        self.totalRaisedValue = campaign.totalAmountRaised.value
        self.totalRaisedNumericalValue = campaign.totalAmountRaised.numericalValue
        self.username = campaign.user.username
        self.userSlug = campaign.user.slug
        self.isStarred = false
    }
    
    init(from campaign: TiltifyMultiSearchQueryCampaignResult) {
        self.id = campaign.id
        self.name = campaign.name
        self.slug = ""
        self.avatar = campaign.factAvatar ?? campaign.userAvatar
        self.status = nil
        self.description = campaign.description
        self.goalCurrency = campaign.tiltifyGoal.currency
        self.goalValue = campaign.tiltifyGoal.value
        self.goalNumericalValue = campaign.tiltifyGoal.numericalValue
        self.totalRaisedCurrency = campaign.tiltifyTotal.currency
        self.totalRaisedValue = campaign.tiltifyTotal.value
        self.totalRaisedNumericalValue = campaign.tiltifyTotal.numericalValue
        self.username = campaign.username
        self.userSlug = campaign.username
        self.isStarred = false
    }
    
    init(from campaign: TiltifyCampaign) {
        self.id = campaign.publicId
        self.name = campaign.name
        self.slug = campaign.slug
        self.avatar = campaign.avatar ?? campaign.user.avatar
        self.status = nil
        self.description = campaign.description
        self.goalCurrency = campaign.goal.currency
        self.goalValue = campaign.goal.value
        self.goalNumericalValue = campaign.goal.numericalValue
        self.totalRaisedCurrency = campaign.totalAmountRaised.currency
        self.totalRaisedValue = campaign.totalAmountRaised.value
        self.totalRaisedNumericalValue = campaign.totalAmountRaised.numericalValue
        self.username = campaign.user.username
        self.userSlug = campaign.user.slug
        self.isStarred = false
    }
    
    init(from campaign: TiltifyAPICampaign) {
        self.id = campaign.id
        self.name = campaign.name
        self.slug = campaign.slug
        self.avatar = campaign.avatar ?? campaign.user.avatar
        self.status = campaign.status
        self.description = campaign.description
        self.goalCurrency = campaign.goal.currency
        self.goalValue = campaign.goal.value
        self.goalNumericalValue = campaign.goal.numericalValue
        self.totalRaisedCurrency = campaign.totalAmountRaised.currency
        self.totalRaisedValue = campaign.totalAmountRaised.value
        self.totalRaisedNumericalValue = campaign.totalAmountRaised.numericalValue
        self.username = campaign.user.username
        self.userSlug = campaign.user.slug
        self.isStarred = false
    }
    
    func updated(fromCauseCampaign campaign: TiltifyCauseCampaign) -> Campaign {
        return Campaign(id: self.id,
                        name: campaign.name,
                        slug: campaign.slug,
                        avatar: campaign.avatar ?? campaign.user.avatar,
                        status: self.status,
                        description: campaign.description,
                        goalCurrency: campaign.goal.currency,
                        goalValue: campaign.goal.value,
                        goalNumericalValue: campaign.goal.numericalValue,
                        totalRaisedCurrency: campaign.totalAmountRaised.currency,
                        totalRaisedValue: campaign.totalAmountRaised.value,
                        totalRaisedNumericalValue: campaign.totalAmountRaised.numericalValue,
                        username: campaign.user.username,
                        userSlug: campaign.user.slug,
                        isStarred: self.isStarred)
    }
    
    func updated(fromCampaign campaign: TiltifyCampaign) -> Campaign {
        return Campaign(id: self.id,
                        name: campaign.name,
                        slug: campaign.slug,
                        avatar: campaign.avatar ?? campaign.user.avatar,
                        status: self.status,
                        description: campaign.description,
                        goalCurrency: campaign.goal.currency,
                        goalValue: campaign.goal.value,
                        goalNumericalValue: campaign.goal.numericalValue,
                        totalRaisedCurrency: campaign.totalAmountRaised.currency,
                        totalRaisedValue: campaign.totalAmountRaised.value,
                        totalRaisedNumericalValue: campaign.totalAmountRaised.numericalValue,
                        username: campaign.user.username,
                        userSlug: campaign.user.slug,
                        isStarred: self.isStarred)
    }
    
    func updated(from campaign: TiltifyAPICampaign) -> Campaign {
        return Campaign(id: self.id,
                        name: campaign.name,
                        slug: campaign.slug,
                        avatar: campaign.avatar ?? campaign.user.avatar,
                        status: self.status,
                        description: campaign.description,
                        goalCurrency: campaign.goal.currency,
                        goalValue: campaign.goal.value,
                        goalNumericalValue: campaign.goal.numericalValue,
                        totalRaisedCurrency: campaign.totalAmountRaised.currency,
                        totalRaisedValue: campaign.totalAmountRaised.value,
                        totalRaisedNumericalValue: campaign.totalAmountRaised.numericalValue,
                        username: campaign.user.username,
                        userSlug: campaign.user.slug,
                        isStarred: self.isStarred)
    }
    
    func updated(fromFact fact: TiltifyFact) -> Campaign {
        return Campaign(id: self.id,
                        name: fact.name,
                        slug: fact.currentSlug,
                        avatar: fact.avatar,
                        status: self.status,
                        description: fact.description,
                        goalCurrency: fact.goal.currency,
                        goalValue: fact.goal.value,
                        goalNumericalValue: fact.goal.numericalValue,
                        totalRaisedCurrency: fact.totalAmountRaised.currency,
                        totalRaisedValue: fact.totalAmountRaised.value,
                        totalRaisedNumericalValue: fact.totalAmountRaised.numericalValue,
                        username: fact.ownership.name,
                        userSlug: fact.ownership.slug,
                        isStarred: self.isStarred)
    }
    
    func setStar(to isStarred: Bool) -> Campaign {
        return Campaign(id: self.id,
                        name: self.name,
                        slug: self.slug,
                        avatar: self.avatar,
                        status: self.status,
                        description: self.description,
                        goalCurrency: self.goalCurrency,
                        goalValue: self.goalValue,
                        goalNumericalValue: self.goalNumericalValue,
                        totalRaisedCurrency: self.totalRaisedCurrency,
                        totalRaisedValue: self.totalRaisedValue,
                        totalRaisedNumericalValue: self.totalRaisedNumericalValue,
                        username: self.username,
                        userSlug: self.userSlug,
                        isStarred: isStarred)
    }
    
}

extension Campaign {
    
    func updateFromAPI() async -> Campaign? {
        
        dataLogger.debug("Updating \(self.id) from the API...")
        
        if let campaignData = await TiltifyAPIClient.shared.getCampaign(withId: id) {
            let apiCampaign = self.updated(from: campaignData)
            do {
                if try await AppDatabase.shared.updateCampaign(apiCampaign, changesFrom: self) {
                    dataLogger.info("\(self.id) Updated stored campaign: \(apiCampaign.id)")
                    
                    await self.updateMilestonesInDatabase(with: await TiltifyAPIClient.shared.getCampaignMilestones(forId: id))
                    await self.updateRewardsInDatabase(with: await TiltifyAPIClient.shared.getCampaignRewards(forId: id))
                    
                    return apiCampaign
                }
            } catch {
                dataLogger.error("\(self.id) Updating stored campaign failed: \(error.localizedDescription)")
            }
        }
        
        return nil
        
    }
    
    func updateMilestonesInDatabase(with apiMilestones: [TiltifyMilestone]) async {
        
        var keyedApiMilestones: [UUID: Milestone] = apiMilestones.reduce(into: [:]) { partialResult, ms in
            partialResult.updateValue(Milestone(from: ms, campaignId: self.id, teamEventId: nil), forKey: ms.publicId)
        }
        
        do {
            let dbMilestones: [Milestone] = try await AppDatabase.shared.fetchSortedMilestones(for: self)
            // For each milestone from the database...
            for dbMilestone in dbMilestones {
                if let apiMilestone = keyedApiMilestones[dbMilestone.id] {
                    // Update it from the API if it exists...
                    keyedApiMilestones.removeValue(forKey: dbMilestone.id)
                    dataLogger.debug("Updating Milestone \(apiMilestone.name)")
                    do {
                        try await AppDatabase.shared.updateMilestone(apiMilestone, changesFrom: dbMilestone)
                    } catch {
                        dataLogger.error("Failed to update Milestone: \(apiMilestone.name): \(error.localizedDescription)")
                    }
                } else {
                    // Remove it from the database if it doesn't...
                    dataLogger.debug("Removing Milestone \(dbMilestone.name)")
                    do {
                        try await AppDatabase.shared.deleteMilestone(dbMilestone)
                    } catch {
                        dataLogger.error("Failed to delete Milestone \(dbMilestone.name): \(error.localizedDescription)")
                    }
                }
            }
            // For each new milestone in the API, save it to the database
            for apiMilestone in keyedApiMilestones.values {
                dataLogger.debug("Creating Milestone: \(apiMilestone.name)")
                do {
                    try await AppDatabase.shared.saveMilestone(apiMilestone)
                } catch {
                    dataLogger.error("Failed to save Milestone \(apiMilestone.name): \(error.localizedDescription)")
                }
            }
        } catch {
            dataLogger.debug("Failed to update Milestones: \(error.localizedDescription)")
        }
        
    }
    
    func updateRewardsInDatabase(with apiRewards: [TiltifyCampaignReward]) async {
        
        var keyedApiRewards: [UUID: Reward] = apiRewards.reduce(into: [:]) { partialResult, reward in
            partialResult.updateValue(Reward(from: reward, campaignId: self.id, teamEventId: nil), forKey: reward.publicId)
        }
        
        do {
            let dbRewards: [Reward] = try await AppDatabase.shared.fetchSortedRewards(for: self)
            // For each reward from the database...
            for dbReward in dbRewards {
                if let apiReward = keyedApiRewards[dbReward.id] {
                    // Update it from the API if it exists...
                    keyedApiRewards.removeValue(forKey: dbReward.id)
                    dataLogger.debug("Updating Reward \(apiReward.name)")
                    do {
                        try await AppDatabase.shared.updateReward(apiReward, changesFrom: dbReward)
                    } catch {
                        dataLogger.error("Failed to update Reward: \(apiReward.name): \(error.localizedDescription)")
                    }
                } else {
                    // Remove it from the database if it doesn't...
                    dataLogger.debug("Removing Reward \(dbReward.name)")
                    do {
                        try await AppDatabase.shared.deleteReward(dbReward)
                    } catch {
                        dataLogger.error("Failed to delete Reward \(dbReward.name): \(error.localizedDescription)")
                    }
                }
            }
            // For each new reward in the API, save it to the database
            for apiReward in keyedApiRewards.values {
                dataLogger.debug("Creating Reward: \(apiReward.name)")
                do {
                    try await AppDatabase.shared.saveReward(apiReward)
                } catch {
                    dataLogger.error("Failed to save Reward \(apiReward.name): \(error.localizedDescription)")
                }
            }
        } catch {
            dataLogger.debug("Failed to update Rewards: \(error.localizedDescription)")
        }
        
    }
    

    
}
