//
//  CampaignWidgetConfigurationIntentHandler.swift
//  Intents Extension
//
//  Created by David Stephens on 26/08/2022.
//

import Foundation
import Intents

class ConfigurationIntentHandler: NSObject, ConfigurationIntentHandling {
    
    func resolveShowMilestonePercentage(for intent: ConfigurationIntent) async -> INBooleanResolutionResult {
        .success(with: intent.showMilestones?.boolValue ?? true)
    }
    
    func resolvePreferFutureMilestones(for intent: ConfigurationIntent) async -> INBooleanResolutionResult {
        .success(with: intent.preferFutureMilestones?.boolValue ?? true)
    }
    
    func resolveShowGoalPercentage(for intent: ConfigurationIntent) async -> INBooleanResolutionResult {
        return .success(with: intent.showGoalPercentage?.boolValue ?? true)
    }
    
    func resolveUseTrueBlackBackground(for intent: ConfigurationIntent) async -> INBooleanResolutionResult {
        return .success(with: intent.useTrueBlackBackground?.boolValue ?? false)
    }
    
    func resolveCampaign(for intent: ConfigurationIntent) async -> INWidgetCampaignResolutionResult {
        guard let campaign = intent.campaign else {
            return .notRequired()
        }
        return .success(with: campaign)
    }
    
    
    func provideCampaignOptionsCollection(for intent: ConfigurationIntent) async throws -> INObjectCollection<INWidgetCampaign> {
        guard let event = try await AppDatabase.shared.fetchRelayFundraisingEvent() else {
            return INObjectCollection(items: [])
        }
        let campaigns = try await AppDatabase.shared.fetchAllCampaigns(for: event)
        let widgetCampaigns = campaigns.sorted { c1, c2 in
            if c1.user.username == "Relay FM" {
                return true
            }
            if c2.user.username == "Relay FM" {
                return false
            }
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
        .map { campaign in
            let prefix: String
            if campaign.user.name == "Relay FM" {
                prefix = "📌 "
            } else if campaign.isStarred {
                prefix = "⭐️ "
            } else {
                prefix = ""
            }
            let widgetCampaign = INWidgetCampaign(identifier: campaign.id.uuidString, display: "\(prefix) \(campaign.user.name) — \(campaign.title)")
            widgetCampaign.slug = campaign.slug
            widgetCampaign.vanity = campaign.user.slug
            return widgetCampaign
        }
        return INObjectCollection(items: widgetCampaigns)
    }
    
}
