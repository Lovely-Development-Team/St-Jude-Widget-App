//
//  Model.swift
//  Model
//
//  Created by David on 22/08/2021.
//

import Foundation
import SwiftUI

struct TiltifyAmount: Codable {
    let currency: String
    let value: String?
}

struct TiltifyMilestone: Codable {
    let amount: TiltifyAmount
    let id: Int
    let name: String
}

struct TiltifyAvatar: Codable {
    let alt: String
    let src: String
    let height: Int?
    let width: Int?
}

struct TiltifyCampaign: Codable {
    let avatar: TiltifyAvatar?
    let goal: TiltifyAmount
    let milestones: [TiltifyMilestone]
    let slug: String
    let status: String
    let team: String?
    let description: String
    let totalAmountRaised: TiltifyAmount
    let name: String
    let originalGoal: TiltifyAmount
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

struct TiltifyUser: Codable {
    let username: String
    let slug: String
}

struct TiltifyCauseCampaign: Codable {
    let name: String
    let goal: TiltifyAmount
    let totalAmountRaised: TiltifyAmount
    let user: TiltifyUser
}

struct TiltifyPublishedCampaign: Codable {
    let node: TiltifyCauseCampaign
}

struct TiltifyPublishedCampaigns: Codable {
    let edges: [TiltifyPublishedCampaign]
}

struct TiltifyColors: Codable {
    let background: String
    let highlight: String
    
    func convert(hex: String) -> Color {
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
    let amountRaised: TiltifyAmount
    let colors: TiltifyColors
    let description: String
    let goal: TiltifyAmount
    let name: String
    let publishedCampaigns: TiltifyPublishedCampaigns
}

struct TiltifyCause: Codable {
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
