//
//  TLDCampaign.swift
//  St Jude
//
//  Created by Ben Cardy on 03/09/2026.
//

struct TLDCampaign {
    static func milestoneReached(name: String) async -> Bool {
        if let campaign = try? await AppDatabase.shared.fetchCampaign(with: TLD_CAMPAIGN),
           let milestone = try? await AppDatabase.shared.fetchSortedMilestones(for: campaign).first(where: { $0.name.lowercased() == name }) {
            return milestone.amount.value <= campaign.totalRaised.numericalValue
        }
        return false
    }
}
