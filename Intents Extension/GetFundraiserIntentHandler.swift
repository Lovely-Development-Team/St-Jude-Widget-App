//
//  GetFundraiserIntentHandler.swift
//  Intents Extension
//
//  Created by Ben Cardy on 07/09/2022.
//

import Foundation
import Intents

class GetFundraiserIntentHandler: NSObject, GetFundraiserIntentHandling {
    
    func handle(intent: GetFundraiserIntent) async -> GetFundraiserIntentResponse {
        guard let campaign = intent.campaign, let vanity = campaign.vanity, let slug = campaign.slug else {
            dataLogger.error("No campaign found for intent")
            return .init(code: .failure, userActivity: nil)
        }
        do {
            let response = try await ApiClient.shared.fetchCampaign(vanity: vanity, slug: slug)
            let campaign = response.data.campaign
            
            let goalAmount = INAmount(from: campaign.goal, showFullCurrencySymbol: false)
            let amountRaised = INAmount(from: campaign.totalAmountRaised, showFullCurrencySymbol: false)
            
            let inMilestones = campaign.milestones.sorted(by: sortMilestones).map { milestone -> INMilestone in
                INMilestone(from: milestone, showFullCurrencySymbol: false)
            }
            
            let inRewards = campaign.rewards.sorted(by: sortRewards).map { reward -> ShortcutReward in
                ShortcutReward(from: reward, showFullCurrencySymbol: false)
            }
            
            let intentResponse = GetFundraiserIntentResponse(code: .success, userActivity: nil)
            let fundraiser = ShortcutCampaignDetails(identifier: campaign.publicId.uuidString, display: campaign.name)
            fundraiser.name = campaign.name
            fundraiser.user = campaign.user.name
            fundraiser.goal = goalAmount
            fundraiser.amountRaised = amountRaised
            fundraiser.milestones = inMilestones
            fundraiser.rewards = inRewards
            intentResponse.fundraiser = fundraiser
            return intentResponse
        } catch {
            dataLogger.error("Error fetching campaign details: \(error.localizedDescription)")
            return .init(code: .failure, userActivity: nil)
        }
    }
    
    func resolveCampaign(for intent: GetFundraiserIntent) async -> ShortcutCampaignResolutionResult {
        guard let campaign = intent.campaign else {
            return .notRequired()
        }
        return .success(with: campaign)
    }
    
    func provideCampaignOptionsCollection(for intent: GetFundraiserIntent, searchTerm: String?) async throws -> INObjectCollection<ShortcutCampaign> {
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
        .filter {
            guard let searchTerm = searchTerm else { return true }
            let lowered = searchTerm.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            return $0.name.lowercased().contains(lowered) || $0.user.name.lowercased().contains(lowered)
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
    
}
