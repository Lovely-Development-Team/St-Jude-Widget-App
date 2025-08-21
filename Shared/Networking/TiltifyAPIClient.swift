//
//  TiltifyAPIClient.swift
//  St Jude
//
//  Created by Ben Cardy on 21/08/2025.
//

import Foundation

class TiltifyAPIClient: APIClient {
    
    let baseUrl = URL(string: "https://v5api.tiltify.com/")!
    static let shared = TiltifyAPIClient()
    
    static let clientId = "86ada7963d7709d11bc771a370497f3e0a223c1d6fa08d6344fa96cbf888e945"
    static let clientSecret = ""
    
    var _token: String = ""
    var _tokenExpiresAt: Date = Date()
    
}

// MARK: Authentication

extension TiltifyAPIClient {
    
    func commonHeaders<T: APIRequest>(for request: T) async -> [String : String] {
        if !(request is TiltifyAuthenticateRequest) {
            return ["Authorization": "Bearer \(await self.getToken())"]
        }
        return [:]
    }
    
    func authenticate() async throws -> TiltifyAuthenticateResponse {
        return try await self.send(TiltifyAuthenticateRequest())
    }
    
    func getToken() async -> String {
        if Date() >= self._tokenExpiresAt {
            do {
                let tokenData = try await authenticate()
                self._token = tokenData.accessToken
                self._tokenExpiresAt = Date().addingTimeInterval(TimeInterval(tokenData.expiresIn - 60))
            } catch {
                self._token = "No token"
            }
        }
        return self._token
    }
    
}

// MARK: Fundraising Event

extension TiltifyAPIClient {
    func getFundraisingEvent() async -> TiltifyFundraisingEvent? {
        do {
            return try await self.send(TiltifyGetFundraisingEventRequest(fundraisingEventId: UUID(uuidString: FUNDRAISING_EVENT_PUBLIC_ID)!)).data
        } catch {
            apiLogger.error("Unable to fetch fundraising event: \(error.localizedDescription)")
        }
        return nil
    }
    
    func getFundraisingEventCampaigns() async -> [TiltifyAPICampaign] {
        var campaigns: [TiltifyAPICampaign] = []
        do {
            var request = TiltifyGetSupportingEventsRequest(fundraisingEventId: UUID(uuidString: FUNDRAISING_EVENT_PUBLIC_ID)!)
            while true {
                let response = try await self.send(request)
                campaigns.append(contentsOf: response.data)
                if let after = response.metadata.after {
                    request = TiltifyGetSupportingEventsRequest(fundraisingEventId: request.fundraisingEventId, after: after)
                } else {
                    break
                }
            }
            return campaigns.filter { $0.user.name != "Relay" }
        } catch {
            apiLogger.error("Unable to fetch supporting events: \(error.localizedDescription)")
        }
        return []
    }
}

// MARK: Campaigns

extension TiltifyAPIClient {
    
    func getCampaign(withId id: UUID) async -> TiltifyAPICampaign? {
        do {
            return try await self.send(TiltifyGetCampaignRequest(campaignId: id)).data
        } catch {
            apiLogger.error("Unable to fetch campaign: \(error.localizedDescription)")
        }
        return nil
    }
    
    func getCampaignMilestones(forId id: UUID) async -> [TiltifyMilestone] {
        var milestones: [TiltifyMilestone] = []
        do {
            var request = TiltifyGetCampaignMilestonesRequest(campaignId: id)
            while true {
                let response = try await self.send(request)
                milestones.append(contentsOf: response.data)
                if let after = response.metadata.after {
                    request = TiltifyGetCampaignMilestonesRequest(campaignId: id, after: after)
                } else {
                    break
                }
            }
            return milestones
        } catch {
            apiLogger.error("Unable to fetch milestones: \(error.localizedDescription)")
        }
        return []
    }
    
    func getCampaignRewards(forId id: UUID) async -> [TiltifyCampaignReward] {
        var rewards: [TiltifyCampaignReward] = []
        do {
            var request = TiltifyGetCampaignRewardsRequest(campaignId: id)
            while true {
                let response = try await self.send(request)
                rewards.append(contentsOf: response.data)
                if let after = response.metadata.after {
                    request = TiltifyGetCampaignRewardsRequest(campaignId: id, after: after)
                } else {
                    break
                }
            }
            return rewards
        } catch {
            apiLogger.error("Unable to fetch rewards: \(error.localizedDescription)")
        }
        return []
    }
    
    func getCampaignDonations(forId id: UUID) async -> [TiltifyDonorsForCampaignDonation] {
        do {
            return try await self.send(TiltifyGetCampaignDonationsRequest(campaignId: id)).data
        } catch {
            apiLogger.error("Unable to fetch donations: \(error.localizedDescription)")
        }
        return []
    }
    
    func getCampaignTopDonor(forId id: UUID) async -> TiltifyTopDonor? {
        do {
            return try await self.send(TiltifyGetCampaignTopDonorsRequest(campaignId: id)).data.first
        } catch {
            apiLogger.error("Unable to fetch top donor: \(error.localizedDescription)")
        }
        return nil
    }
    
    func getCampaignWithMilestones(forId id: UUID) async -> TIltifyCampaignWithMilestones? {
        if let campaign = await self.getCampaign(withId: id) {
            return TIltifyCampaignWithMilestones(
                campaign: campaign,
                milestones: await self.getCampaignMilestones(forId: id)
            )
        }
        return nil
    }
    
}

// MARK: Scores

extension TiltifyAPIClient {
    
    func buildScoreRequest() -> URLRequest {
        var request = URLRequest(url: URL(string: "https://stjude-scoreboard.snailedit.online/api/co-founders")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        return request
    }
    
    func fetchScore() async -> Score? {
        do {
            let request = buildScoreRequest()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let decoded = String(data: data, encoding: .utf8) {
                dataLogger.debug("Score: \(decoded)")
            } else {
                dataLogger.debug("Score: not decodable")
            }
            return try JSONDecoder().decode(Score.self, from: data)
        } catch {
            dataLogger.error("Fetching score failed: \(error.localizedDescription)")
        }
        return nil
    }
    
}
