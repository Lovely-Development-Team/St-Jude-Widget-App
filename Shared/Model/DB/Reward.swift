//
//  Reward.swift
//  St Jude
//
//  Created by Ben Cardy on 25/08/2022.
//

import Foundation
import GRDB

/// The Reward struct.
struct Reward: Identifiable, Hashable {
    var id: UUID { publicId }
    let publicId: UUID
    let name: String
    let description: String
    private let amountCurrency: String
    private let amountValue: Double
    var amount: ResolvedTiltifyAmount {
        ResolvedTiltifyAmount(currency: amountCurrency, value: amountValue)
    }
    let imageSrc: String?
    let campaignId: UUID?
    let teamEventId: UUID?
    let quantity: Int?
    let quantityRemaining: Int?
}

extension Reward: Codable, FetchableRecord, MutablePersistableRecord {
    fileprivate enum Columns {
        static let publicId = Column(CodingKeys.publicId)
        static let name = Column(CodingKeys.name)
        static let description = Column(CodingKeys.description)
        static let amountCurrency = Column(CodingKeys.amountCurrency)
        static let amountValue = Column(CodingKeys.amountValue)
        static let imageSrc = Column(CodingKeys.imageSrc)
        static let quantity = Column(CodingKeys.quantity)
        static let quantityRemaining = Column(CodingKeys.quantityRemaining)
    }
    
    static let campaign = belongsTo(Campaign.self)
    static let teamEvent = belongsTo(TeamEvent.self)
    
    var campaign: QueryInterfaceRequest<Campaign> {
        request(for: Reward.campaign)
    }
    
    var teamEvent: QueryInterfaceRequest<TeamEvent> {
        request(for: Reward.teamEvent)
    }
}

extension Reward {
    init (from reward: TiltifyCampaignReward, campaignId: UUID? = nil, teamEventId: UUID? = nil) {
        self.publicId = reward.publicId
        self.name = reward.name
        self.description = reward.description
        self.amountCurrency = reward.amount.currency
        self.amountValue = reward.amount.numericalValue
        self.imageSrc = reward.image?.src
        self.campaignId = campaignId
        self.teamEventId = teamEventId
        self.quantity = reward.quantity
        self.quantityRemaining = reward.quantityRemaining
    }
    
    func updated(fromReward reward: TiltifyCampaignReward, campaignId: UUID? = nil, teamEventId: UUID? = nil) -> Reward {
        return Reward(publicId: self.publicId,
                      name: reward.name,
                      description: reward.description,
                      amountCurrency: reward.amount.currency,
                      amountValue: reward.amount.numericalValue,
                      imageSrc: reward.image?.src,
                      campaignId: campaignId,
                      teamEventId: teamEventId,
                      quantity: reward.quantity,
                      quantityRemaining: reward.quantityRemaining)
    }
}
