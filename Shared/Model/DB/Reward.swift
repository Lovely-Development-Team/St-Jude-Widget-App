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
    var id: UUID
    let name: String
    let description: String
    private let amountCurrency: String
    private let amountValue: Double
    var amount: ResolvedTiltifyAmount {
        ResolvedTiltifyAmount(currency: amountCurrency, value: amountValue)
    }
    let imageSrc: String?
    let campaignId: UUID
}

extension Reward: Codable, FetchableRecord, MutablePersistableRecord {
    fileprivate enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let description = Column(CodingKeys.description)
        static let amountCurrency = Column(CodingKeys.amountCurrency)
        static let amountValue = Column(CodingKeys.amountValue)
        static let imageSrc = Column(CodingKeys.imageSrc)
    }
    
    static let campaign = belongsTo(Campaign.self)
    
    var campaign: QueryInterfaceRequest<Campaign> {
        request(for: Reward.campaign)
    }
}

extension Reward {
    init (from reward: TiltifyCampaignReward, campaignId: UUID) {
        self.id = reward.publicId
        self.name = reward.name
        self.description = reward.description
        self.amountCurrency = reward.amount.currency
        self.amountValue = reward.amount.numericalValue
        self.imageSrc = reward.image?.src
        self.campaignId = campaignId
    }
    
    func updated(fromReward reward: TiltifyCampaignReward, campaignId: UUID) -> Reward {
        return Reward(id: self.id,
                      name: reward.name,
                      description: reward.description,
                      amountCurrency: reward.amount.currency,
                      amountValue: reward.amount.numericalValue,
                      imageSrc: reward.image?.src,
                      campaignId: campaignId)
    }
}
