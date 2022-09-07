//
//  GetFundraisingEventIntentHandler.swift
//  Intents Extension
//
//  Created by Ben Cardy on 07/09/2022.
//

import Foundation
import Intents

class GetFundraisingEventIntentHandler: NSObject, GetMainFundraisingEventIntentHandling {
    
    func handle(intent: GetMainFundraisingEventIntent) async -> GetMainFundraisingEventIntentResponse {
        do {
            let apiResponse = try await ApiClient.shared.fetchCause()
            let fundraisingEvent = apiResponse.data.fundraisingEvent
            
            let goalAmount = INAmount(from: fundraisingEvent.goal, showFullCurrencySymbol: false)
            let amountRaised = INAmount(from: fundraisingEvent.amountRaised, showFullCurrencySymbol: false)
            
            let intentResponse = GetMainFundraisingEventIntentResponse(code: .success, userActivity: nil)
            let fundraiser = ShortcutCampaignDetails(identifier: fundraisingEvent.publicId.uuidString, display: fundraisingEvent.name)
            
            let campaignApiResponse = try await ApiClient.shared.fetchCampaign()
            let campaign = campaignApiResponse.data.campaign
            
            let inMilestones = campaign.milestones.sorted(by: sortMilestones).map { milestone -> INMilestone in
                INMilestone(from: milestone, showFullCurrencySymbol: false)
            }
            
            let inRewards = campaign.rewards.sorted(by: sortRewards).map { reward -> ShortcutReward in
                ShortcutReward(from: reward, showFullCurrencySymbol: false)
            }
            
            fundraiser.name = fundraisingEvent.name
            fundraiser.user = "Relay FM"
            fundraiser.goal = goalAmount
            fundraiser.amountRaised = amountRaised
            fundraiser.milestones = inMilestones
            fundraiser.rewards = inRewards
            intentResponse.event = fundraiser
            return intentResponse
            
        } catch {
            return .init(code: .failure, userActivity: nil)
        }
    }
}
