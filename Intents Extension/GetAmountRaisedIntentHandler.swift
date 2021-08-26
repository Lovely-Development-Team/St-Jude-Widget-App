//
//  GetAmountRaisedIntentHandler.swift
//  GetAmountRaisedIntentHandler
//
//  Created by David on 25/08/2021.
//

import Foundation

class GetAmountRaisedIntentHandler: NSObject, GetAmountRaisedIntentHandling {
    let apiClient = ApiClient.shared
    
    func handle(intent: GetAmountRaisedIntent, completion: @escaping (GetAmountRaisedIntentResponse) -> Void) {
        _ = apiClient.fetchCampaign { result in
            switch result {
            case .failure(let error):
                dataLogger.error("Failed to fetch campaign \(error.localizedDescription)")
                completion(.init(code: .failure, userActivity: nil))
                return
            case .success(let response):
                let campaign = response.data.campaign
                let totalRaised: TiltifyAmount = campaign.totalAmountRaised
                let intentResponse = GetAmountRaisedIntentResponse(code: .success, userActivity: nil)
                let amountRaised = INAmount(from: totalRaised, showFullCurrencySymbol: false)
                intentResponse.amountRaised = amountRaised
                completion(intentResponse)
            }
        }
    }
    
    
}
