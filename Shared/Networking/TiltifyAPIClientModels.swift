//
//  TiltifyAPIClientModels.swift
//  St Jude
//
//  Created by Ben Cardy on 21/08/2025.
//

import Foundation

// MARK: Authentication

struct TiltifyAuthenticateResponse: Decodable {
    let accessToken: String
    let expiresIn: Int
    let tokenType: String
    let scope: String
    let refreshToken: String?
}

struct TiltifyAuthenticateRequestBody: Encodable {
    let clientId: String
    let clientSecret: String
    let scope: String
    let grantType: String = "client_credentials"
}

struct TiltifyAuthenticateRequest: JSONAPIRequest {
    typealias Response = TiltifyAuthenticateResponse
    typealias RequestBody = TiltifyAuthenticateRequestBody
    var resourceName: String = "oauth/token"
    
    var body: TiltifyAuthenticateRequestBody? {
        TiltifyAuthenticateRequestBody(clientId: TiltifyAPIClient.clientId,
                                        clientSecret: TiltifyAPIClient.clientSecret,
                                        scope: "public")
    }
    
}


// MARK: Fundraising Event

struct TiltifyFundraisingEvent: Decodable {
    let id: UUID
    let name: String
    let status: String
    let description: String
    let url: String
    let slug: String
    let goal: TiltifyAmount
    let totalAmountRaised: TiltifyAmount
}

struct TiltifyFundraisingEventResponse: Decodable {
    let data: TiltifyFundraisingEvent
}

struct TiltifyGetFundraisingEventRequest: EmptyAPIRequest {
    typealias Response = TiltifyFundraisingEventResponse
    let fundraisingEventId: UUID
    var resourceName: String {
        "api/public/fundraising_events/\(fundraisingEventId)"
    }
}

// MARK: Campaigns

struct TiltifyAPICampaign: Decodable {
    let id: UUID
    let name: String
    let status: String
    let user: TiltifyUser
    let description: String
    let slug: String
    let goal: TiltifyAmount
    let totalAmountRaised: TiltifyAmount
    let avatar: TiltifyAvatar?
}

struct TiltifyPaginationMeta: Decodable {
    let after: String?
    let limit: Int
    let before: String?
}

struct TiltifyGetCampaignResponse: Decodable {
    let data: TiltifyAPICampaign
}

struct TiltifyGetSupportingEventsResponse: Decodable {
    let data: [TiltifyAPICampaign]
    let metadata: TiltifyPaginationMeta
}

protocol TiltifyAPIPaginatedRequest: EmptyAPIRequest {
    var after: String? { get }
    var limit: Int { get }
}
extension TiltifyAPIPaginatedRequest {
    var parameters: [URLQueryItem] {
        var params: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: String(limit))
        ]
        if let after {
            params.append(URLQueryItem(name: "after", value: after))
        }
        return params
    }
}

struct TiltifyGetSupportingEventsRequest: TiltifyAPIPaginatedRequest {
    typealias Response = TiltifyGetSupportingEventsResponse
    let fundraisingEventId: UUID
    var after: String?
    var limit: Int = 50
    var resourceName: String {
        "api/public/fundraising_events/\(fundraisingEventId)/supporting_events"
    }
}

struct TiltifyGetCampaignRequest: EmptyAPIRequest {
    typealias Response = TiltifyGetCampaignResponse
    let campaignId: UUID
    var resourceName: String {
        "api/public/campaigns/\(campaignId)"
    }
}

struct TiltifyGetCampaignMilestonesResponse: Decodable {
    let data: [TiltifyMilestone]
    let metadata: TiltifyPaginationMeta
}

struct TiltifyGetCampaignMilestonesRequest: TiltifyAPIPaginatedRequest {
    typealias Response = TiltifyGetCampaignMilestonesResponse
    let campaignId: UUID
    var after: String?
    var limit: Int = 50
    var resourceName: String {
        "api/public/campaigns/\(campaignId)/milestones"
    }
}

struct TiltifyGetCampaignRewardsResponse: Decodable {
    let data: [TiltifyCampaignReward]
    let metadata: TiltifyPaginationMeta
}

struct TiltifyGetCampaignRewardsRequest: TiltifyAPIPaginatedRequest {
    typealias Response = TiltifyGetCampaignRewardsResponse
    let campaignId: UUID
    var after: String?
    var limit: Int = 50
    var resourceName: String {
        "api/public/campaigns/\(campaignId)/rewards"
    }
}

struct TiltifyGetCampaignDonations: Decodable {
    let data: [TiltifyDonorsForCampaignDonation]
}

struct TiltifyGetCampaignDonationsRequest: TiltifyAPIPaginatedRequest {
    typealias Response = TiltifyGetCampaignDonations
    let campaignId: UUID
    var after: String?
    var limit: Int = 50
    var resourceName: String {
        "api/public/campaigns/\(campaignId)/donations"
    }
}

struct TiltifyTopDonor: Decodable {
    let name: String
    let amount: TiltifyAmount
}

struct TiltifyGetTopDonorResponse: Decodable {
    let data: [TiltifyTopDonor]
}

struct TiltifyGetCampaignTopDonorsRequest: TiltifyAPIPaginatedRequest {
    typealias Response = TiltifyGetTopDonorResponse
    let campaignId: UUID
    var after: String?
    var limit: Int = 1
    var resourceName: String {
        "api/public/campaigns/\(campaignId)/donor_leaderboard"
    }
}

struct TIltifyCampaignWithMilestones {
    let campaign: TiltifyAPICampaign
    let milestones: [TiltifyMilestone]
}

struct TiltifyCampaignPollOption: Decodable {
    let amountRaised: TiltifyAmount
    let id: UUID
    let insertedAt: String
    let name: String
    let updatedAt: String
}

struct TiltifyCampaignPoll: Decodable {
    let active: Bool
    let amountRaised: TiltifyAmount
    let id: UUID
    let insertedAt: String
    let name: String
    let options: [TiltifyCampaignPollOption]
    let updatedAt: String
}

struct TiltifyGetCampaignPollsResponse: Decodable {
    let data: [TiltifyCampaignPoll]
}

struct TiltifyGetCampaignPollsRequest: TiltifyAPIPaginatedRequest {
    typealias Response = TiltifyGetCampaignPollsResponse
    let campaignId: UUID
    var after: String?
    var limit: Int = 50
    
    var resourceName: String {
        "api/public/campaigns/\(campaignId)/polls"
    }
}
