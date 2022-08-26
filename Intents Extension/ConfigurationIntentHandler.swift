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
        let widgetCampaigns = campaigns.map { campaign in
            let widgetCampaign = INWidgetCampaign(identifier: campaign.id.uuidString, display: "\(campaign.title) (\(campaign.user.name))")
            widgetCampaign.slug = campaign.slug
            widgetCampaign.vanity = campaign.user.slug
            return widgetCampaign
        }
        return INObjectCollection(items: widgetCampaigns)
    }
    
}
