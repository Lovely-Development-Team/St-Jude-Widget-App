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
    let teamEventId: UUID?
    
    // From the API
    let endsAtString: String?
    
    // Manual endsAt override, used for when endsAt = nil and campaign.active goes false
    // to display poll for a bit after it closes
    var manualClosedAtString: String?
}

extension Poll: Codable, FetchableRecord, MutablePersistableRecord {
    fileprivate enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let active = Column(CodingKeys.active)
        static let totalRaisedValue = Column(CodingKeys.totalRaisedValue)
        static let totalRaisedCurrency = Column(CodingKeys.totalRaisedCurrency)
        static let endsAtString = Column(CodingKeys.endsAtString)
        static let manualClosedAtString = Column(CodingKeys.manualClosedAtString)
    }
    
    static let pollOptions = hasMany(PollOption.self)
    var pollOptions: QueryInterfaceRequest<PollOption> {
        request(for: Poll.pollOptions)
    }
    
    static let parentCampaign = belongsTo(Campaign.self)
    var parentCampaign: QueryInterfaceRequest<Campaign> {
        request(for: Poll.parentCampaign)
    }
    
    static let parentTeamEvent = belongsTo(TeamEvent.self)
    var parentTeamEvent: QueryInterfaceRequest<TeamEvent> {
        request(for: Poll.parentTeamEvent)
    }
}

extension Poll {
    init(from poll: TiltifyCampaignPoll, campaignId: UUID? = nil, teamEventId: UUID? = nil) {
        self.id = poll.id
        self.name = poll.name
        self.active = poll.active
        self.totalRaisedValue = poll.amountRaised.numericalValue
        self.totalRaisedCurrency = poll.amountRaised.currency
        self.campaignId = campaignId
        self.teamEventId = teamEventId
        self.endsAtString = poll.endsAt
        self.manualClosedAtString = nil
    }
    
    var amountRaised: TiltifyAmount {
        return TiltifyAmount(currency: self.totalRaisedCurrency, value: String(self.totalRaisedValue))
    }
    
    func parentCampaignName() async -> String? {
        // Attempt to get the parent campaign name
        do {
            if let parentCampaign = try await AppDatabase.shared.fetchParentCampaign(for: self) {
                return parentCampaign.title
            }
        } catch {
            dataLogger.error("Failed to fetch parent campaign of poll: \(self.name): \(error.localizedDescription)")
        }
        
        // Attempt to get the parent team event name
        do {
            if let parentTeamEvent = try await AppDatabase.shared.fetchParentTeamEvent(for: self) {
                return parentTeamEvent.name
            }
        } catch {
            dataLogger.error("Failed to fetch parent team event of poll: \(self.name): \(error.localizedDescription)")
        }
        
        return nil
    }
    
    var pollURL: URL? {
        guard let parentId = self.campaignId ?? self.teamEventId else {
            return nil
        }
        
        var parentIdString = parentId.uuidString
        
        if parentIdString == FUNDRAISING_EVENT_PUBLIC_ID {
            parentIdString = RELAY_SUBCAMPAIGN_ID
        }
        
        return URL(string: "https://donate.tiltify.com/\(parentIdString)/incentives?pollPublicId=\(self.id.uuidString.lowercased())")!
    }
    
    var endsAt: Date? {
        if let endsAtString = self.endsAtString?.swiftCompatible8601DateString {
            return ISO8601DateFormatter().date(from: endsAtString)
        }
        
        return nil
    }
    
    var manualClosedAt: Date? {
        if let manualClosedAtString = self.manualClosedAtString?.swiftCompatible8601DateString {
            return ISO8601DateFormatter().date(from: manualClosedAtString)
        }
        
        return nil
    }
    
    static var samplePoll: Poll {
        return Poll(id: UUID(), name: "Who would win?", active: true, totalRaisedValue: 100, totalRaisedCurrency: "USD", campaignId: UUID(), teamEventId: nil, endsAtString: nil, manualClosedAtString: nil)
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
    
    var amountRaised: TiltifyAmount {
        return TiltifyAmount(currency: self.amountRaisedCurrency, value: String(self.amountRaisedValue))
    }
    
    func isMax(options: [PollOption]) -> Bool {
        guard self.amountRaised.numericalValue != 0 else { return false }
        let maxValue = options.map { $0.amountRaisedValue }.max()
        return self.amountRaised.numericalValue == maxValue
    }
    
    func percentageOfPoll(parentPoll: Poll) -> Double {
        guard parentPoll.amountRaised.numericalValue > 0,
                self.amountRaised.numericalValue > 0,
                parentPoll.amountRaised.numericalValue >= self.amountRaised.numericalValue else {
            return 0
        }
        return (self.amountRaised.numericalValue / parentPoll.amountRaised.numericalValue)
    }
    
    static var samplePollOptions: [PollOption] {
        let option1 = PollOption(id: UUID(),
                                 name: "L2CU",
                                 amountRaisedValue: 95,
                                 amountRaisedCurrency: "USD",
                                 pollId: UUID())
        let option2 = PollOption(id: UUID(),
                                 name: "R2D2",
                                 amountRaisedValue: 5,
                                 amountRaisedCurrency: "USD",
                                 pollId: UUID())
        return [option1, option2]
    }
}
