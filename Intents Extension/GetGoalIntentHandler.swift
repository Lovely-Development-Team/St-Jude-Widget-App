//
//  GetGoalIntentHandler.swift
//  GetGoalIntentHandler
//
//  Created by David on 25/08/2021.
//

import Foundation

class GetGoalIntentHandler: NSObject, GetGoalIntentHandling {
    let apiClient = ApiClient.shared
    
    func handle(intent: GetGoalIntent, completion: @escaping (GetGoalIntentResponse) -> Void) {
        _ = apiClient.fetchCampaign { result in
            switch result {
            case .failure(let error):
                dataLogger.error("Failed to fetch campaign \(error.localizedDescription)")
                completion(.init(code: .failure, userActivity: nil))
                return
            case .success(let response):
                let campaign = response.data.campaign
                let currentGoal = campaign.goal
                let intentResponse = GetGoalIntentResponse(code: .success, userActivity: nil)
                let goalAmount = INAmount(from: currentGoal, showFullCurrencySymbol: false)
                intentResponse.currentGoal = goalAmount
                completion(intentResponse)
            }
        }
    }
    
}
