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
        TiltifyUser(username: username, slug: userSlug)
    }
    let fundraisingEventId: UUID
}

//extension Campaign: Codable {
//    enum CodingKeys: CodingKey {
//        case id
//        case publicId
//        case name
//        case slug
//        case goal
//        case totalAmountRaised
//        case username
//        case userSlug
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//        try container.encode(publicId, forKey: .publicId)
//        try container.encode(name, forKey: .name)
//        try container.encode(slug, forKey: .slug)
//        try container.encode(goal, forKey: .goal)
//        try container.encode(totalAmountRaised, forKey: .totalAmountRaised)
//        try container.encode(user.username, forKey: .username)
//        try container.encode(user.slug, forKey: .userSlug)
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decode(Int64.self, forKey: .id)
//        self.publicId = try container.decode(String.self, forKey: .publicId)
//        self.name = try container.decode(String.self, forKey: .name)
//        self.slug = try container.decode(String.self, forKey: .slug)
//        self.goal = try container.decode(TiltifyAmount.self, forKey: .goal)
//        self.totalAmountRaised = try container.decode(TiltifyAmount.self, forKey: .totalAmountRaised)
//        let username = try container.decode(String.self, forKey: .username)
//        let userSlug = try container.decode(String.self, forKey: .userSlug)
//        self.user = TiltifyUser(username: username, slug: userSlug)
//    }
//}

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
    }
    
    static let fundraisingEvent = belongsTo(FundraisingEvent.self)
    
    var fundraisingEvent: QueryInterfaceRequest<FundraisingEvent> {
        request(for: Campaign.fundraisingEvent)
    }
}

extension Campaign {
    init(from campaign: TiltifyCauseCampaign, fundraiserId: UUID) {
        self.id = campaign.publicId
        self.name = campaign.name
        self.slug = campaign.slug
        self.avatar = nil
        self.status = nil
        self.description = nil
        self.goalCurrency = campaign.goal.currency
        self.goalValue = campaign.goal.value
        self.totalRaisedCurrency = campaign.totalAmountRaised.currency
        self.totalRaisedValue = campaign.totalAmountRaised.value
        self.username = campaign.user.username
        self.userSlug = campaign.user.slug
        self.fundraisingEventId = fundraiserId
    }
    
    func update(fromCauseCampaign campaign: TiltifyCauseCampaign, fundraiserId: UUID) -> Campaign {
        return Campaign(id: self.id,
                        name: campaign.name,
                        slug: campaign.slug,
                        avatar: self.avatar,
                        status: self.status,
                        description: self.description,
                        goalCurrency: campaign.goal.currency,
                        goalValue: campaign.goal.value,
                        totalRaisedCurrency: campaign.totalAmountRaised.currency,
                        totalRaisedValue: campaign.totalAmountRaised.value,
                        username: campaign.user.username,
                        userSlug: campaign.user.slug,
                        fundraisingEventId: fundraiserId)
    }
}
