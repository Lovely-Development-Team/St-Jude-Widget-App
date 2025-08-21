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
        if let teamEvent = await TiltifyAPIClient.shared.getCampaignWithMilestones(forId: TEAM_EVENT_ID) {
            let goalAmount = INAmount(from: teamEvent.campaign.goal, showFullCurrencySymbol: false)
            let amountRaised = INAmount(from: teamEvent.campaign.totalAmountRaised, showFullCurrencySymbol: false)
            
            let intentResponse = GetMainFundraisingEventIntentResponse(code: .success, userActivity: nil)
            let fundraiser = ShortcutCampaignDetails(identifier: teamEvent.campaign.id.uuidString, display: teamEvent.campaign.name)
            
            let inMilestones = teamEvent.milestones.sorted(by: sortMilestones).map { milestone -> INMilestone in
                INMilestone(from: milestone, showFullCurrencySymbol: false)
            }
            
            fundraiser.name = teamEvent.campaign.name
            fundraiser.user = "Relay"
            fundraiser.goal = goalAmount
            fundraiser.amountRaised = amountRaised
            fundraiser.milestones = inMilestones
            fundraiser.rewards = []
            intentResponse.event = fundraiser
            return intentResponse
        } else {
            return .init(code: .failure, userActivity: nil)
        }
    }
}
