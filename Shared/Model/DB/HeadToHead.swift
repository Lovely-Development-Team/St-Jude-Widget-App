//
//  HeadToHead.swift
//  St Jude
//
//  Created by Ben Cardy on 30/08/2023.
//

import Foundation
import GRDB

/// The HeadToHead struct.
struct HeadToHead: Identifiable, Hashable {
    let id: UUID
    let campaignId1: UUID?
    let campaignId2: UUID?
}

extension HeadToHead: Codable, FetchableRecord, MutablePersistableRecord {
    fileprivate enum Columns {
        static let id = Column(CodingKeys.id)
    }
    
    static let campaign1ForeignKey = ForeignKey(["campaignId1"])
    static let campaign2ForeignKey = ForeignKey(["campaignId2"])
    
    static let campaign1 = belongsTo(Campaign.self, using: campaign1ForeignKey).forKey("campaign1")
    static let campaign2 = belongsTo(Campaign.self, using: campaign2ForeignKey).forKey("campaign2")
    
    var campaign1: QueryInterfaceRequest<Campaign> {
        request(for: HeadToHead.campaign1)
    }
    
    var campaign2: QueryInterfaceRequest<Campaign> {
        request(for: HeadToHead.campaign2)
    }
}

struct HeadToHeadWithCampaigns: Decodable, FetchableRecord {
    var headToHead: HeadToHead
    var campaign1: Campaign
    var campaign2: Campaign
}
