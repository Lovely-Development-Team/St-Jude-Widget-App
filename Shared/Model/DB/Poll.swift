//
//  Poll.swift
//  St Jude
//
//  Created by Justin Hamilton on 9/10/26.
//

import Foundation
import GRDB

struct Poll: Identifiable, Hashable {
    let id: UUID
    let name: String
    let active: Bool
    let totalRaisedValue: Double
    let totalRaisedCurrency: String
    let campaignId: UUID?
}

extension Poll: Codable, FetchableRecord, MutablePersistableRecord {
    fileprivate enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let active = Column(CodingKeys.active)
        static let totalRaisedValue = Column(CodingKeys.totalRaisedValue)
        static let totalRaisedCurrency = Column(CodingKeys.totalRaisedCurrency)
    }
    
    static let pollOptions = hasMany(PollOption.self)
    var pollOptions: QueryInterfaceRequest<PollOption> {
        request(for: Poll.pollOptions)
    }
    
    static let parentCampaign = belongsTo(Campaign.self)
    var parentCampaign: QueryInterfaceRequest<Campaign> {
        request(for: Poll.parentCampaign)
    }
}

extension Poll {
    init(from poll: TiltifyCampaignPoll, campaignId: UUID? = nil) {
        self.id = poll.id
        self.name = poll.name
        self.active = poll.active
        self.totalRaisedValue = poll.amountRaised.numericalValue
        self.totalRaisedCurrency = poll.amountRaised.currency
        self.campaignId = campaignId
    }
}

// MARK: - PollOption

struct PollOption: Identifiable, Hashable {
    let id: UUID
    let name: String
    let amountRaisedValue: Double
    let amountRaisedCurrency: String
    let pollId: UUID?
}

extension PollOption: Codable, FetchableRecord, MutablePersistableRecord {
    fileprivate enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let amountRaisedValue = Column(CodingKeys.amountRaisedValue)
        static let amountRaisedCurrency = Column(CodingKeys.amountRaisedCurrency)
    }
    
    static let parentPoll = belongsTo(Poll.self)
    var parentPoll: QueryInterfaceRequest<Poll> {
        request(for: PollOption.parentPoll)
    }
}

extension PollOption {
    init(from pollOption: TiltifyCampaignPollOption, pollId: UUID? = nil) {
        self.id = pollOption.id
        self.name = pollOption.name
        self.amountRaisedValue = pollOption.amountRaised.numericalValue
        self.amountRaisedCurrency = pollOption.amountRaised.currency
        self.pollId = pollId
    }
}
