//
//  Model.swift
//  Model
//
//  Created by David on 22/08/2021.
//

import Foundation

struct TiltifyAmount: Codable {
    let currency: String
    let value: String
}

struct TiltifyMilestone: Codable {
    let amount: TiltifyAmount
    let id: Int
    let name: String
}

struct TiltifyAvatar: Codable {
    let alt: String
    let src: String
    let height: Int
    let width: Int
}

struct TiltifyCampaign: Codable {
    let avatar: TiltifyAvatar?
    let goal: TiltifyAmount
    let milestones: [TiltifyMilestone]
    let id: Int
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
    let milestoneADoubleValue = Double(milestoneA.amount.value)
    let milestoneBDoubleValue = Double(milestoneB.amount.value)
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
