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
    private let totalRaisedCurrency: String
    private let totalRaisedValue: String?
    var totalRaised: TiltifyAmount {
        TiltifyAmount(currency: totalRaisedCurrency, value: totalRaisedValue)
    }
    private let username: String
    private let userSlug: String
    var user: TiltifyUser {
        TiltifyUser(username: username, slug: userSlug, avatar: avatar)
    }
    var isStarred: Bool
    let fundraisingEventId: UUID
    
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
        let value = max(goal.numericalValue - totalRaised.numericalValue, 0)
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = goal.currency
        currencyFormatter.currencySymbol = "$"
        let descriptionString = currencyFormatter.string(from: value as NSNumber) ?? "\(goal.currency) 0"
        return descriptionString
    }
    
    var title: String {
        username == "Relay FM" ? "Relay FM" : name
    }
    
    var url: URL {
        URL(string: "https://tiltify.com/@\(user.slug)/\(slug)")!
    }
    
    var directDonateURL: URL {
        URL(string: "https://donate.tiltify.com/@\(user.slug)/\(slug)")!
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
        static let totalRaisedCurrency = Column(CodingKeys.totalRaisedCurrency)
        static let totalRaisedValue = Column(CodingKeys.totalRaisedValue)
        static let username = Column(CodingKeys.username)
        static let userSlug = Column(CodingKeys.userSlug)
        static let isStarred = Column(CodingKeys.isStarred)
    }
    
    static let fundraisingEvent = belongsTo(FundraisingEvent.self)
    var fundraisingEvent: QueryInterfaceRequest<FundraisingEvent> {
        request(for: Campaign.fundraisingEvent)
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
    init(from campaign: TiltifyCauseCampaign, fundraiserId: UUID) {
        self.id = campaign.publicId
        self.name = campaign.name
        self.slug = campaign.slug
        self.avatar = campaign.user.avatar
        self.status = nil
        self.description = campaign.description
        self.goalCurrency = campaign.goal.currency
        self.goalValue = campaign.goal.value
        self.totalRaisedCurrency = campaign.totalAmountRaised.currency
        self.totalRaisedValue = campaign.totalAmountRaised.value
        self.username = campaign.user.username
        self.userSlug = campaign.user.slug
        self.isStarred = false
        self.fundraisingEventId = fundraiserId
    }
    
    init(from campaign: TiltifyCampaign, fundraiserId: UUID) {
        self.id = campaign.publicId
        self.name = campaign.name
        self.slug = campaign.slug
        self.avatar = campaign.user.avatar
        self.status = nil
        self.description = campaign.description
        self.goalCurrency = campaign.goal.currency
        self.goalValue = campaign.goal.value
        self.totalRaisedCurrency = campaign.totalAmountRaised.currency
        self.totalRaisedValue = campaign.totalAmountRaised.value
        self.username = campaign.user.username
        self.userSlug = campaign.user.slug
        self.isStarred = false
        self.fundraisingEventId = fundraiserId
    }
    
    func updated(fromCauseCampaign campaign: TiltifyCauseCampaign, fundraiserId: UUID) -> Campaign {
        return Campaign(id: self.id,
                        name: campaign.name,
                        slug: campaign.slug,
                        avatar: campaign.user.avatar,
                        status: self.status,
                        description: campaign.description,
                        goalCurrency: campaign.goal.currency,
                        goalValue: campaign.goal.value,
                        totalRaisedCurrency: campaign.totalAmountRaised.currency,
                        totalRaisedValue: campaign.totalAmountRaised.value,
                        username: campaign.user.username,
                        userSlug: campaign.user.slug,
                        isStarred: self.isStarred,
                        fundraisingEventId: fundraiserId)
    }
    
    func updated(fromCampaign campaign: TiltifyCampaign, fundraiserId: UUID) -> Campaign {
        return Campaign(id: self.id,
                        name: campaign.name,
                        slug: campaign.slug,
                        avatar: campaign.user.avatar,
                        status: self.status,
                        description: campaign.description,
                        goalCurrency: campaign.goal.currency,
                        goalValue: campaign.goal.value,
                        totalRaisedCurrency: campaign.totalAmountRaised.currency,
                        totalRaisedValue: campaign.totalAmountRaised.value,
                        username: campaign.user.username,
                        userSlug: campaign.user.slug,
                        isStarred: self.isStarred,
                        fundraisingEventId: fundraiserId)
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
                        totalRaisedCurrency: self.totalRaisedCurrency,
                        totalRaisedValue: self.totalRaisedValue,
                        username: self.username,
                        userSlug: self.userSlug,
                        isStarred: isStarred,
                        fundraisingEventId: self.fundraisingEventId)
    }
    
}
