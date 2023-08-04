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
        if let teamEvent = await ApiClient.shared.fetchTeamEvent() {
            let goalAmount = INAmount(from: teamEvent.goal, showFullCurrencySymbol: false)
            let amountRaised = INAmount(from: teamEvent.totalAmountRaised, showFullCurrencySymbol: false)
            
            let intentResponse = GetMainFundraisingEventIntentResponse(code: .success, userActivity: nil)
            let fundraiser = ShortcutCampaignDetails(identifier: teamEvent.publicId.uuidString, display: teamEvent.name)
            
            let inMilestones = teamEvent.milestones.sorted(by: sortMilestones).map { milestone -> INMilestone in
                INMilestone(from: milestone, showFullCurrencySymbol: false)
            }
            
            let inRewards = teamEvent.rewards.sorted(by: sortRewards).map { reward -> ShortcutReward in
                ShortcutReward(from: reward, showFullCurrencySymbol: false)
            }
            
            fundraiser.name = teamEvent.name
            fundraiser.user = "Relay FM"
            fundraiser.goal = goalAmount
            fundraiser.amountRaised = amountRaised
            fundraiser.milestones = inMilestones
            fundraiser.rewards = inRewards
            intentResponse.event = fundraiser
            return intentResponse
        } else {
            return .init(code: .failure, userActivity: nil)
        }
    }
}
