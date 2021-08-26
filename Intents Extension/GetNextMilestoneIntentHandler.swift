//
//  GetCurrentMilestoneIntentHandler.swift
//  GetCurrentMilestoneIntentHandler
//
//  Created by David on 25/08/2021.
//

import Foundation

class GetNextMilestoneIntentHandler: NSObject, GetNextMilestoneIntentHandling {
    let apiClient = ApiClient.shared
    
    func handle(intent: GetNextMilestoneIntent, completion: @escaping (GetNextMilestoneIntentResponse) -> Void) {
        _ = apiClient.fetchCampaign { result in
            switch result {
            case .failure(let error):
                dataLogger.error("Failed to fetch campaign \(error.localizedDescription)")
                completion(.init(code: .failure, userActivity: nil))
                return
            case .success(let response):
                let campaign = response.data.campaign
                guard let totalRaised = Double(campaign.totalAmountRaised.value) else {
                    completion(.init(code: .badApiResponse, userActivity: nil))
                    return
                }
                let nextMilestone = TiltifyWidgetData.nextMilestone(at: totalRaised, in: campaign.milestones)
                guard let milestone = nextMilestone ?? TiltifyWidgetData.previousMilestone(at: totalRaised, in: campaign.milestones) else {
                    completion(.init(code: .failedToFindMilestone, userActivity: nil))
                    return
                }
                let intentResponse = GetNextMilestoneIntentResponse(code: .success, userActivity: nil)
                let inMilestone = INMilestone(from: milestone, showFullCurrencySymbol: false)
                intentResponse.milestone = inMilestone
                completion(intentResponse)
            }
        }
    }  
}
