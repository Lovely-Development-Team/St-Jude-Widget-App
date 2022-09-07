//
//  ListMilestonesIntentHandler.swift
//  ListMilestonesIntentHandler
//
//  Created by David on 25/08/2021.
//

import Foundation
import Intents

class ListMilestonesIntentHandler: NSObject, ListMilestonesIntentHandling {
    let apiClient = ApiClient.shared
    
    func resolveCampaign(for intent: ListMilestonesIntent) async -> ShortcutCampaignResolutionResult {
        guard let campaign = intent.campaign else {
            return .notRequired()
        }
        return .success(with: campaign)
    }
    
    func provideCampaignOptionsCollection(for intent: ListMilestonesIntent, searchTerm: String?) async throws -> INObjectCollection<ShortcutCampaign> {
        guard let event = try await AppDatabase.shared.fetchRelayFundraisingEvent() else {
            return INObjectCollection(items: [])
        }
        let campaigns = try await AppDatabase.shared.fetchAllCampaigns(for: event)
        let widgetCampaigns = campaigns.sorted { c1, c2 in
            if c1.isStarred && !c2.isStarred {
                return true
            }
            if c2.isStarred && !c1.isStarred {
                return false
            }
            if c1.name.lowercased() == c2.name.lowercased() {
                return c1.id.uuidString < c2.id.uuidString
            }
            return c1.name.lowercased() < c2.name.lowercased()
        }
        .map { campaign -> ShortcutCampaign in
            let prefix = campaign.isStarred ? "⭐️ " : ""
            let widgetCampaign = ShortcutCampaign(identifier: campaign.id.uuidString, display: "\(prefix) \(campaign.user.name) — \(campaign.title)")
            widgetCampaign.slug = campaign.slug
            widgetCampaign.vanity = campaign.user.slug
            return widgetCampaign
        }
        return INObjectCollection(items: widgetCampaigns)
    }
    
    func handle(intent: ListMilestonesIntent, completion: @escaping (ListMilestonesIntentResponse) -> Void) {
        guard let campaign = intent.campaign, let vanity = campaign.vanity, let slug = campaign.slug else {
            completion(.init(code: .failure, userActivity: nil))
            return
        }
        _ = apiClient.fetchCampaign(vanity: vanity, slug: slug) { result in
            switch result {
            case .failure(let error):
                dataLogger.error("Failed to fetch campaign \(error.localizedDescription)")
                completion(.init(code: .failure, userActivity: nil))
                return
            case .success(let response):
                let campaign = response.data.campaign
                let milestones = campaign.milestones
                let intentResponse = ListMilestonesIntentResponse(code: .success, userActivity: nil)
                let inMilestones = milestones.sorted(by: sortMilestones).map { milestone -> INMilestone in
                    INMilestone(from: milestone, showFullCurrencySymbol: false)
                }
                intentResponse.milestones = inMilestones
                completion(intentResponse)
            }
        }
    }
    
    
}
