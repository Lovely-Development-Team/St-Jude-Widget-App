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
    var id: UUID { publicId }
    let publicId: UUID
    let name: String
    private let amountCurrency: String
    private let amountValue: Double
    var amount: ResolvedTiltifyAmount {
        ResolvedTiltifyAmount(currency: amountCurrency, value: amountValue)
    }
    let campaignId: UUID?
    let teamEventId: UUID?
}

extension Milestone: Codable, FetchableRecord, MutablePersistableRecord {
    fileprivate enum Columns {
        static let publicId = Column(CodingKeys.publicId)
        static let name = Column(CodingKeys.name)
        static let amountCurrency = Column(CodingKeys.amountCurrency)
        static let amountValue = Column(CodingKeys.amountValue)
    }
    
    static let campaign = belongsTo(Campaign.self)
    static let teamEvent = belongsTo(TeamEvent.self)
    
    var campaign: QueryInterfaceRequest<Campaign> {
        request(for: Milestone.campaign)
    }
    
    var teamEvent: QueryInterfaceRequest<TeamEvent> {
        request(for: Milestone.teamEvent)
    }
    
}

extension Milestone {
    
    init (from milestone: TiltifyMilestone, campaignId: UUID? = nil, teamEventId: UUID? = nil) {
        self.publicId = milestone.publicId
        self.name = milestone.name
        self.amountCurrency = milestone.amount.currency
        self.amountValue = milestone.amount.numericalValue
        self.campaignId = campaignId
        self.teamEventId = teamEventId
    }
    
    func updated(fromMilestone milestone: TiltifyMilestone, campaignId: UUID? = nil, teamEventId: UUID? = nil) -> Milestone {
        return Milestone(publicId: self.publicId,
                         name: milestone.name,
                         amountCurrency: milestone.amount.currency,
                         amountValue: milestone.amount.numericalValue,
                         campaignId: campaignId, teamEventId: teamEventId)
    }
}
