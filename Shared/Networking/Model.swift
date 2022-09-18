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
    let id: Int
    let name: String
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
    let id: Int
    let publicId: UUID
    let name: String
    let description: String
    let amount: TiltifyAmount
    let image: TiltifyCampaignRewardImage?
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
    let description: String
}

struct TiltifyPublishedCampaign: Codable {
    let node: TiltifyCauseCampaign
}

struct TiltifyPublishedCampaigns: Codable {
    let edges: [TiltifyPublishedCampaign]
}

struct TiltifyColors: Codable, Hashable {
    let background: String
    let highlight: String
    
    private func convert(hex: String) -> Color {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return Color.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return Color(UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        ))
    }
    
    var backgroundColor: Color {
        convert(hex: background)
    }
    
    var highlightColor: Color {
        convert(hex: highlight)
    }
    
}

struct TiltifyFundraisingEvent: Codable {
    let publicId: UUID
    let slug: String
    let amountRaised: TiltifyAmount
    let colors: TiltifyColors
    let description: String
    let goal: TiltifyAmount
    let name: String
    let publishedCampaigns: TiltifyPublishedCampaigns
    
    var percentageReached: Double? {
        return calcPercentage(goal: goal.value ?? "0", total: amountRaised.value ?? "0")
    }
    
    var percentageReachedDescription: String? {
        guard let percentageReached = percentageReached else {
            return nil
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter.string(from: percentageReached as NSNumber)
    }
    
}

struct TiltifyCause: Codable, Hashable {
    let publicId: UUID
    let name: String
    let slug: String
}

struct TiltifyCauseData: Codable {
    let cause: TiltifyCause
    let fundraisingEvent: TiltifyFundraisingEvent
}

struct TiltifyCauseResponse: Codable {
    let data: TiltifyCauseData
}


struct TiltifyCampaignsForCausePagination: Codable {
    let hasNextPage: Bool
    let limit: Int
    let offset: Int
    let total: Int
}

struct TiltifyCampaignsForCausePublishedCampaigns: Codable {
    let edges: [TiltifyPublishedCampaign]
    let pagination: TiltifyCampaignsForCausePagination
}

struct TiltifyCampaignsForCauseFundraisingEvent: Codable {
    let publishedCampaigns: TiltifyCampaignsForCausePublishedCampaigns
}

struct TiltifyCampaignsForCauseData: Codable {
    let fundraisingEvent: TiltifyCampaignsForCauseFundraisingEvent
}

struct TiltifyCampaignsForCauseResponse: Codable {
    let data: TiltifyCampaignsForCauseData
}


struct TiltifyDonorsForCampaignDonationIncentive: Codable {
    let type: String
}

struct TiltifyDonorsForCampaignDonation: Codable {
    let id: Int
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
