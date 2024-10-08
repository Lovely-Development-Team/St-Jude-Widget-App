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
        user.name == "Relay FM" ? "Relay FM" : name
    }
    
}

struct TiltifyData: Codable {
    let campaign: TiltifyCampaign
}

struct TiltifyResponse: Codable {
    let data: TiltifyData
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
    let incentives: [TiltifyDonorsForCampaignDonationIncentive]
    let completedAt: String
    
    var donationDate: Date? {
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
