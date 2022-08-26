//
//  GetPreviousMilestoneIntentHandler.swift
//  GetPreviousMilestoneIntentHandler
//
//  Created by David on 25/08/2021.
//

import Foundation

class GetPreviousMilestoneIntentHandler: NSObject, GetPreviousMilestoneIntentHandling {
    let apiClient = ApiClient.shared
    
    func handle(intent: GetPreviousMilestoneIntent, completion: @escaping (GetPreviousMilestoneIntentResponse) -> Void) {
        _ = apiClient.fetchCampaign { result in
            switch result {
            case .failure(let error):
                dataLogger.error("Failed to fetch campaign \(error.localizedDescription)")
                completion(.init(code: .failure, userActivity: nil))
                return
            case .success(let response):
                let campaign = response.data.campaign
                guard let totalRaised = Double(campaign.totalAmountRaised.value ?? "0") else {
                    completion(.init(code: .badApiResponse, userActivity: nil))
                    return
                }
                guard let milestone = TiltifyWidgetData.previousMilestone(at: totalRaised, in: campaign.milestones.map { Milestone(from: $0, campaignId: campaign.publicId) }) else {
                    completion(.init(code: .failedToFindMilestone, userActivity: nil))
                    return
                }
                let intentResponse = GetPreviousMilestoneIntentResponse(code: .success, userActivity: nil)
                let inMilestone = INMilestone(from: milestone, showFullCurrencySymbol: false)
                intentResponse.milestone = inMilestone
                completion(intentResponse)
            }
        }
    }
}
