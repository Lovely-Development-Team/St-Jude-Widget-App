//
//  TLDCampaign.swift
//  St Jude
//
//  Created by Ben Cardy on 03/09/2026.
//

import Foundation

struct TLDCampaign {
    
    enum Milestone: String {
        case nice = "57e917af-2c5e-4ae2-8017-f7c85804663a"
        case alternateAppIcons = "263a9b9c-e4cb-4464-bcd0-fcdbed5ef78d"
        case wildWestWidgets = "885a6c7d-8c8b-462f-9c1e-5395c67e681f"
        case pollWidgets = "bf7ae94a-2d20-45ba-8a28-826a6e917322"
        case headToHeadWidgets = "cf675f43-1763-445b-87c0-cca964f79cda"
    }
    
    static func milestoneReached(_ milestone: Milestone) async -> Bool {
        if let campaign = try? await AppDatabase.shared.fetchCampaign(with: TLD_CAMPAIGN),
           let milestone = try? await AppDatabase.shared.fetchSortedMilestones(for: campaign).first(where: { $0.publicId == UUID(uuidString: milestone.rawValue)! }) {
            return milestone.amount.value <= campaign.totalRaised.numericalValue
        }
        return false
    }
}
