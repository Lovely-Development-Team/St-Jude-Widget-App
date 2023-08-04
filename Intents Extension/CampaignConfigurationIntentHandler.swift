//
//  CampaignConfigurationIntentHandler.swift
//  Intents Extension
//
//  Created by Ben Cardy on 05/09/2022.
//

import Foundation
import Intents


class CampaignConfigurationIntentHandler: NSObject, CampaignLockScreenConfigurationIntentHandling {
        
    func resolveShowGoalPercentage(for intent: ConfigurationIntent) async -> INBooleanResolutionResult {
        return .success(with: intent.showGoalPercentage?.boolValue ?? true)
    }
    
    func resolveCampaign(for intent: ConfigurationIntent) async -> INWidgetCampaignResolutionResult {
        guard let campaign = intent.campaign else {
            return .notRequired()
        }
        return .success(with: campaign)
    }
    
    func provideCampaignOptionsCollection(for intent: CampaignLockScreenConfigurationIntent) async throws -> INObjectCollection<INWidgetCampaign> {
        let campaigns = try await AppDatabase.shared.fetchAllCampaigns()
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
        .map { campaign -> INWidgetCampaign in
            let prefix = campaign.isStarred ? "⭐️ " : ""
            let widgetCampaign = INWidgetCampaign(identifier: campaign.id.uuidString, display: "\(prefix) \(campaign.user.name) — \(campaign.title)")
            widgetCampaign.slug = campaign.slug
            widgetCampaign.vanity = campaign.user.slug
            return widgetCampaign
        }
        return INObjectCollection(items: widgetCampaigns)
    }
    
}
