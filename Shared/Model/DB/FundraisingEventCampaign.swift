//
//  FundraisingEventCampaign.swift
//  St Jude
//
//  Created by David Stephens on 21/08/2022.
//

import Foundation
import GRDB

struct FundraisingEventCampaign: Identifiable, Hashable {
    var id: Int64?
    let fundraisingEventId: Int64
    let campaignId: Int64
    
    static let fundraisingEvent = belongsTo(FundraisingEvent.self)
    static let campaign = belongsTo(Campaign.self)
}

extension FundraisingEventCampaign: Codable, FetchableRecord, MutablePersistableRecord {
    fileprivate enum Columns {
        static let id = Column(CodingKeys.id)
        static let fundraisingEventId = Column(CodingKeys.fundraisingEventId)
        static let campaignId = Column(CodingKeys.campaignId)
    }
    
    // Update auto-incremented id upon successful insertion
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
