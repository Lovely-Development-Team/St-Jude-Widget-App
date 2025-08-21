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
            let goalAmount = INAmount(from: teamEvent.data.fact.goal, showFullCurrencySymbol: false)
            let amountRaised = INAmount(from: teamEvent.data.fact.totalAmountRaised, showFullCurrencySymbol: false)
            
            let intentResponse = GetMainFundraisingEventIntentResponse(code: .success, userActivity: nil)
            let fundraiser = ShortcutCampaignDetails(identifier: teamEvent.data.fact.id.uuidString, display: teamEvent.data.fact.name)
            
            let inMilestones = teamEvent.data.fact.milestones.sorted(by: sortMilestones).map { milestone -> INMilestone in
                INMilestone(from: milestone, showFullCurrencySymbol: false)
            }
            
            let inRewards = teamEvent.data.fact.rewards.sorted(by: sortRewards).map { reward -> ShortcutReward in
                ShortcutReward(from: reward, showFullCurrencySymbol: false)
            }
            
            fundraiser.name = teamEvent.data.fact.name
            fundraiser.user = "Relay"
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
