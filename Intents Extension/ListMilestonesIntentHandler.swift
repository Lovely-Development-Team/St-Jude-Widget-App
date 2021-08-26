//
//  ListMilestonesIntentHandler.swift
//  ListMilestonesIntentHandler
//
//  Created by David on 25/08/2021.
//

import Foundation

class ListMilestonesIntentHandler: NSObject, ListMilestonesIntentHandling {
    let apiClient = ApiClient.shared
    
    func handle(intent: ListMilestonesIntent, completion: @escaping (ListMilestonesIntentResponse) -> Void) {
        _ = apiClient.fetchCampaign { result in
            switch result {
            case .failure(let error):
                dataLogger.error("Failed to fetch campaign \(error.localizedDescription)")
                completion(.init(code: .failure, userActivity: nil))
                return
            case .success(let response):
                let campaign = response.data.campaign
                let milestones = campaign.milestones
                let intentResponse = ListMilestonesIntentResponse(code: .success, userActivity: nil)
                let inMilestones = milestones.sorted(by: sortMilestones).map { milestone -> INMilestone in
                    INMilestone(from: milestone, showFullCurrencySymbol: false)
                }
                intentResponse.milestones = inMilestones
                completion(intentResponse)
            }
        }
    }
    
    
}
