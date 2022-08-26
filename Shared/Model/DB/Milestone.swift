//
//  Milestone.swift
//  St Jude
//
//  Created by Ben Cardy on 25/08/2022.
//

import Foundation
import GRDB

/// The Milestone struct.
struct Milestone: Identifiable, Hashable {
    var id: Int
    let name: String
    private let amountCurrency: String
    private let amountValue: Double
    var amount: ResolvedTiltifyAmount {
        ResolvedTiltifyAmount(currency: amountCurrency, value: amountValue)
    }
    let campaignId: UUID
}

extension Milestone: Codable, FetchableRecord, MutablePersistableRecord {
    fileprivate enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let amountCurrency = Column(CodingKeys.amountCurrency)
        static let amountValue = Column(CodingKeys.amountValue)
    }
    
    static let campaign = belongsTo(Campaign.self)
    
    var campaign: QueryInterfaceRequest<Campaign> {
        request(for: Milestone.campaign)
    }
}

extension Milestone {
    init (from milestone: TiltifyMilestone, campaignId: UUID) {
        self.id = milestone.id
        self.name = milestone.name
        self.amountCurrency = milestone.amount.currency
        self.amountValue = milestone.amount.numericalValue
        self.campaignId = campaignId
    }
    
    func updated(fromMilestone milestone: TiltifyMilestone, campaignId: UUID) -> Milestone {
        return Milestone(id: self.id,
                         name: milestone.name,
                         amountCurrency: milestone.amount.currency,
                         amountValue: milestone.amount.numericalValue,
                         campaignId: campaignId)
    }
}
