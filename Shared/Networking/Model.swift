//
//  Model.swift
//  Model
//
//  Created by David on 22/08/2021.
//

import Foundation
import SwiftUI

struct ResolvedTiltifyAmount {
    let currency: String
    let value: Double
    
    func description(showFullCurrencySymbol: Bool) -> String {
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = currency
        
        let originalSymbol = currencyFormatter.currencySymbol
        let originalCode = currencyFormatter.currencyCode
        
        currencyFormatter.currencyCode = "USD"
        if !showFullCurrencySymbol {
            currencyFormatter.currencySymbol = "$"
        } else {
            currencyFormatter.currencySymbol = "USD"
        }
        
        let descriptionString = currencyFormatter.string(from: value as NSNumber) ?? "\(currency) 0"
        currencyFormatter.currencySymbol = originalSymbol
        currencyFormatter.currencyCode = originalCode
        
        return descriptionString
    }
}

struct TiltifyAmount: Codable {
    let currency: String
    let value: String?
    
    var numericalValue: Double {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US")
        return Double(truncating: numberFormatter.number(from: value ?? "0") ?? 0)
    }
    
    func description(showFullCurrencySymbol: Bool) -> String {
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = currency
        
        let originalSymbol = currencyFormatter.currencySymbol
        let originalCode = currencyFormatter.currencyCode
        
        currencyFormatter.currencyCode = "USD"
        if !showFullCurrencySymbol {
            currencyFormatter.currencySymbol = "$"
        } else {
            currencyFormatter.currencySymbol = "USD"
        }
        
        let descriptionString = currencyFormatter.string(from: numericalValue as NSNumber) ?? "\(currency) 0"
        currencyFormatter.currencySymbol = originalSymbol
        currencyFormatter.currencyCode = originalCode
        
        return descriptionString
    }
    
}

struct TiltifyMilestone: Codable {
    let amount: TiltifyAmount
    let name: String
    let publicId: UUID
    let active: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, publicId, name, amount, active
    }
    
    init(amount: TiltifyAmount, name: String, publicId: UUID) {
        self.amount = amount
        self.name = name
        self.publicId = publicId
        self.active = true
    }
    
    // Custom decoder to handle the two possible keys for the 'id' property
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Try decoding from "publicId" first. If that key isn't present,
        // it will fall back and try decoding from "id".
        self.publicId = try container.decodeIfPresent(UUID.self, forKey: .publicId) ?? container.decode(UUID.self, forKey: .id)

        // Decode the rest of the properties as usual
        self.amount = try container.decode(TiltifyAmount.self, forKey: .amount)
        self.name = try container.decode(String.self, forKey: .name)
        self.active = try container.decode(Bool.self, forKey: .active)
    }
    
    // Custom encoder to standardize the output
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // When encoding, always write the value to the "id" key for consistency
        try container.encode(self.publicId, forKey: .id)
        try container.encode(self.amount, forKey: .amount)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.active, forKey: .active)
    }
}

struct TiltifyAvatar: Codable, Hashable {
    let alt: String
    let src: String
    let height: Int?
    let width: Int?
}

struct TiltifyCampaignRewardImage: Codable {
    let src: String
}

struct TiltifyCampaignReward: Codable {
    let publicId: UUID
    let name: String
    let description: String
    let amount: TiltifyAmount
    let image: TiltifyCampaignRewardImage?
    let active: Bool
    let ownerUsageType: String?
    let quantity: Int?
    let quantityRemaining: Int?
    
    // Define all possible keys that might appear in the JSON
    private enum CodingKeys: String, CodingKey {
        case id, publicId, name, description, amount, image, active, ownerUsageType, quantity, quantityRemaining
    }

    // Custom decoder to handle the two possible keys for the 'id' property
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Try decoding from "publicId" first. If that key is not present,
        // it will fall back and try decoding from "id".
        self.publicId = try container.decodeIfPresent(UUID.self, forKey: .publicId) ?? container.decode(UUID.self, forKey: .id)

        // Decode the rest of the properties as usual
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.amount = try container.decode(TiltifyAmount.self, forKey: .amount)
        self.image = try container.decodeIfPresent(TiltifyCampaignRewardImage.self, forKey: .image)
        self.active = try container.decode(Bool.self, forKey: .active)
        self.ownerUsageType = try container.decodeIfPresent(String.self, forKey: .ownerUsageType)
        self.quantity = try container.decodeIfPresent(Int.self, forKey: .quantity)
        self.quantityRemaining = try container.decodeIfPresent(Int.self, forKey: .quantityRemaining)
    }
    
    // Custom encoder to standardize the output
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // When encoding, always write the value to the "id" key for consistency
        try container.encode(self.publicId, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.description, forKey: .description)
        try container.encode(self.amount, forKey: .amount)
        try container.encodeIfPresent(self.image, forKey: .image)
        try container.encode(self.active, forKey: .active)
        try container.encodeIfPresent(self.ownerUsageType, forKey: .ownerUsageType)
        try container.encodeIfPresent(self.quantity, forKey: .quantity)
        try container.encodeIfPresent(self.quantityRemaining, forKey: .quantityRemaining)
    }
    
}

struct TiltifyCampaign: Codable {
    let publicId: UUID
    let avatar: TiltifyAvatar?
    let goal: TiltifyAmount
    let milestones: [TiltifyMilestone]
    let slug: String
    let status: String
    let team: String?
    let user: TiltifyUser
    let description: String
    let totalAmountRaised: TiltifyAmount
    let name: String
    let originalGoal: TiltifyAmount
    let rewards: [TiltifyCampaignReward]
        
    var title: String {
        user.name == "Relay" ? "Relay" : name
    }
    
}

struct TiltifyData: Codable {
    let campaign: TiltifyCampaign
}

struct TiltifyResponse: Codable {
    let data: TiltifyData
}

struct TiltifyOwnership: Codable {
    let id: UUID
    let name: String
    let slug: String
}

struct TiltifyFact: Codable {
    let id: UUID
    let currentSlug: String
    let totalAmountRaised: TiltifyAmount
    let avatar: TiltifyAvatar?
    let goal: TiltifyAmount
    let originalGoal: TiltifyAmount
    let name: String
    let description: String
    let ownership: TiltifyOwnership
    let milestones: [TiltifyMilestone]
    let rewards: [TiltifyCampaignReward]
    let topDonation: TiltifyDonorsForCampaignDonation?
}

struct TiltifyData2025: Codable {
    let fact: TiltifyFact
}

struct TiltifyResponse2025: Codable {
    let data: TiltifyData2025
}

func sortMilestones(_ milestoneA: TiltifyMilestone, _ milestoneB: TiltifyMilestone) -> Bool {
    let milestoneADoubleValue = Double(milestoneA.amount.value ?? "0")
    let milestoneBDoubleValue = Double(milestoneB.amount.value ?? "0")
    guard let milestoneAValue = milestoneADoubleValue else {
        guard milestoneBDoubleValue != nil else {
            return false
        }
        return milestoneA.name < milestoneB.name
    }
    guard let milestoneBValue = milestoneBDoubleValue else {
        return true
    }
    if milestoneAValue == milestoneBValue {
        return milestoneA.name < milestoneB.name
    }
    return milestoneAValue < milestoneBValue
}

func sortRewards(_ rewardA: TiltifyCampaignReward, _ rewardB: TiltifyCampaignReward) -> Bool {
    let rewardADoubleValue = Double(rewardA.amount.value ?? "0")
    let rewardBDoubleValue = Double(rewardB.amount.value ?? "0")
    guard let rewardAValue = rewardADoubleValue else {
        guard rewardBDoubleValue != nil else {
            return false
        }
        return rewardA.name < rewardB.name
    }
    guard let rewardBValue = rewardBDoubleValue else {
        return true
    }
    if rewardAValue == rewardBValue {
        return rewardA.name < rewardB.name
    }
    return rewardAValue < rewardBValue
}

struct TiltifyUser: Codable, Hashable {
    let username: String
    let slug: String
    let avatar: TiltifyAvatar?
    
    var name: String {
        if username.contains("@") {
            return username.components(separatedBy: "@")[0]
        }
        return username
    }
    
}

struct TiltifyCauseCampaign: Codable {
    let publicId: UUID
    let name: String
    let slug: String
    let goal: TiltifyAmount
    let totalAmountRaised: TiltifyAmount
    let user: TiltifyUser
    let avatar: TiltifyAvatar?
    let description: String?
}

struct TiltifyDonorsForCampaignDonationIncentive: Codable {
    let type: String
}

struct TiltifyDonorsForCampaignDonation: Codable {
    let id: UUID
    let amount: TiltifyAmount
    let donorName: String
    let donorComment: String?
    let incentives: [TiltifyDonorsForCampaignDonationIncentive]?
    let completedAt: String?
    
    var donationDate: Date? {
        guard let completedAt else { return nil }
        let parsedCompletedAt = String(completedAt.split(separator: ".")[0]) + "Z"
        let isoDateFormatter = ISO8601DateFormatter()
        return isoDateFormatter.date(from: parsedCompletedAt)
    }
    
}

struct TiltifyDonorsForCampaignDonationNode: Codable {
    let node: TiltifyDonorsForCampaignDonation
}

struct TiltifyDonorsForCampaignDonations: Codable {
    let edges: [TiltifyDonorsForCampaignDonationNode]
}

struct TiltifyDonorsForCampaignCampaign: Codable {
    let donations: TiltifyDonorsForCampaignDonations
    let topDonation: TiltifyDonorsForCampaignDonation?
}

struct TiltifyDonorsForCampaignData: Codable {
    let campaign: TiltifyDonorsForCampaignCampaign
}

struct TiltifyDonorsForCampaignResponse: Codable {
    let data: TiltifyDonorsForCampaignData
}


struct TiltifyDonorsForCampaignData2025: Codable {
    let fact: TiltifyDonorsForCampaignCampaign
}

struct TiltifyDonorsForCampaignResponse2025: Codable {
    let data: TiltifyDonorsForCampaignData2025
}


struct TiltifyTeamEvent: Codable {
    let publicId: UUID
    let goal: TiltifyAmount
    let milestones: [TiltifyMilestone]
    let rewards: [TiltifyCampaignReward]
    let slug: String
    let description: String
    let totalAmountRaised: TiltifyAmount
    let name: String
}

struct TiltifyTeamEventData: Codable {
    let teamEvent: TiltifyTeamEvent
}

struct TiltifyTeamEventResponse: Codable {
    let data: TiltifyTeamEventData
}

struct TiltifySupportingCampaignsPageInfo: Codable {
    let endCursor: String?
    let startCursor: String?
    let hasNextPage: Bool
    let hasPreviousPage: Bool
}

struct TiltifySupportingCampaignNode: Codable {
    let cursor: String
    let node: TiltifyCauseCampaign
}

struct TiltifySupportingCampaigns: Codable {
    let edges: [TiltifySupportingCampaignNode]
    let pageInfo: TiltifySupportingCampaignsPageInfo
}

struct TiltifySupportingCampaignsTeamEvent: Codable {
    let supportingCampaigns: TiltifySupportingCampaigns
}

struct TiltifySupportingCampaignsData: Codable {
    let teamEvent: TiltifySupportingCampaignsTeamEvent
}

struct TiltifySupportingCampaignsResponse: Codable {
    let data: TiltifySupportingCampaignsData
}


struct ScoreItem: Codable {
    let score: Double
    
    static let zero = ScoreItem(score: 0)    
}

struct Score: Codable {
    let myke: ScoreItem
    let stephen: ScoreItem
}


struct TiltifyMultiSearchQueryCampaignResult: Codable {
    let id: UUID
    let name: String
    let username: String
    let description: String
    let userAvatar: TiltifyAvatar?
    let factAvatar: TiltifyAvatar?
    let goal: Double
    let totalAmountRaised: Double
    
    var tiltifyGoal: TiltifyAmount {
        TiltifyAmount(currency: "USD", value: String(goal))
    }
    var tiltifyTotal: TiltifyAmount {
        TiltifyAmount(currency: "USD", value: String(totalAmountRaised))
    }
}

struct TiltifyMultiSearchQueryResult: Codable {
    let hits: [TiltifyMultiSearchQueryCampaignResult]
    let totalHits: Int
}

struct TiltifyMultiSearchResult: Codable {
    let results: [TiltifyMultiSearchQueryResult]
}
