//
//  TiltifyWidgetData.swift
//  TiltifyWidgetData
//
//  Created by David on 23/08/2021.
//

import Foundation

struct TiltifyWidgetData {
    let name: String
    private let totalRaisedRaw: String
    var totalRaised: Double? {
        Double(totalRaisedRaw)
    }
    func totalRaisedDescription(showFullCurrencySymbol: Bool) -> String {
        
        guard let totalRaised = totalRaised else {
            return totalRaisedRaw
        }
        
        let originalSymbol = currencyFormatter.currencySymbol
        let originalCode = currencyFormatter.currencyCode
        currencyFormatter.currencyCode = "USD"
        if !showFullCurrencySymbol {
            currencyFormatter.currencySymbol = "$"
        } else {
            currencyFormatter.currencySymbol = "USD"
        }
        
        let descriptionString = currencyFormatter.string(from: totalRaised as NSNumber) ?? totalRaisedRaw
        currencyFormatter.currencySymbol = originalSymbol
        currencyFormatter.currencyCode = originalCode
        
        return descriptionString
    }
    func totalRaisedAccessibilityDescription(showFullCurrencySymbol: Bool) -> String {
        let totalRaisedString = totalRaisedDescription(showFullCurrencySymbol: showFullCurrencySymbol)
        let goalDescriptionString = goalDescription(showFullCurrencySymbol: showFullCurrencySymbol)
        if let percent = percentageReachedDescription {
            return "\(totalRaisedString) raised, \(percent) of \(goalDescriptionString)"
        }
        return "\(totalRaisedString) of \(goalDescriptionString) raised"
    }
    private let goalRaw: String
    var goal: Double? {
        Double(goalRaw)
    }
    func goalDescription(showFullCurrencySymbol: Bool) -> String {
        guard let goal = goal else {
            return goalRaw
        }
        let originalSymbol = currencyFormatter.currencySymbol
        let originalCode = currencyFormatter.currencyCode
        currencyFormatter.currencyCode = "USD"
        if !showFullCurrencySymbol {
            currencyFormatter.currencySymbol = "$"
        } else {
            currencyFormatter.currencySymbol = "USD"
        }
        let descriptionString = currencyFormatter.string(from: goal as NSNumber) ?? goalRaw
        currencyFormatter.currencySymbol = originalSymbol
        currencyFormatter.currencyCode = originalCode
        return descriptionString
    }
    let milestones: [TiltifyMilestone]
    let previousMilestone: TiltifyMilestone?
    let nextMilestone: TiltifyMilestone?
    let futureMilestones: [TiltifyMilestone]
    
    private let currencyCode: String
    let currencyFormatter: NumberFormatter
    let percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    init(from campaign: TiltifyCampaign) {
        self.name = campaign.name
        self.currencyCode = campaign.totalAmountRaised.currency
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        currencyFormatter = formatter
        self.totalRaisedRaw = campaign.totalAmountRaised.value
        self.goalRaw = campaign.goal.value
        self.milestones = campaign.milestones.sorted(by: sortMilestones)
        if let totalRaised = Double(campaign.totalAmountRaised.value) {
            self.previousMilestone = Self.previousMilestone(at: totalRaised, in: self.milestones)
            self.nextMilestone = Self.nextMilestone(at: totalRaised, in: self.milestones)
            self.futureMilestones = Self.futureMilestones(at: totalRaised, in: self.milestones)
        } else {
            self.previousMilestone = nil
            self.nextMilestone = nil
            self.futureMilestones = []
        }
    }
    
    var percentageReached: Double? {
        return calcPercentage(goal: goalRaw, total: totalRaisedRaw)
    }
    var percentageReachedDescription: String? {
        guard let percentageReached = calcPercentage(goal: goalRaw, total: totalRaisedRaw) else {
            return nil
        }
        return percentageFormatter.string(from: percentageReached as NSNumber)
    }
    
    static func previousMilestone(at totalRaised: Double, in milestones: [TiltifyMilestone]) -> TiltifyMilestone? {
        return milestones.last { milestone in
            guard let milestoneValue = Double(milestone.amount.value) else {
                dataLogger.warning("Failed to convert milestone value '\(milestone.amount.value)' to double")
                return false
            }
            return milestoneValue < totalRaised
        }
    }
    
    static func nextMilestone(at totalRaised: Double, in milestones: [TiltifyMilestone]) -> TiltifyMilestone? {
        return milestones.first { milestone in
            guard let milestoneValue = Double(milestone.amount.value) else {
                dataLogger.warning("Failed to convert milestone value '\(milestone.amount.value)' to double")
                return false
            }
            return milestoneValue >= totalRaised
        }
    }
    
    static func futureMilestones(at totalRaised: Double, in milestones: [TiltifyMilestone]) -> [TiltifyMilestone] {
        return milestones.filter { milestone in
            guard let milestoneValue = Double(milestone.amount.value) else {
                dataLogger.warning("Failed to convert milestone value '\(milestone.amount.value)' to double")
                return false
            }
            return milestoneValue >= totalRaised
        }
    }
    
    func percentage(ofMilestone Milestone: TiltifyMilestone) -> Double? {
        guard let totalRaised = totalRaised else {
            return nil
        }
        guard let goal = Double(Milestone.amount.value) else {
            return nil
        }
        return totalRaised/goal
    }
    
    func percentageDescription(for milestone: TiltifyMilestone) -> String {
        guard let milestonePercentage = self.percentage(ofMilestone: milestone) else {
            dataLogger.warning("Failed to calculate percentage of milestone: \(String(reflecting: milestone))")
            return "Unknown"
        }
        guard let description = percentageFormatter.string(from: milestonePercentage as NSNumber) else {
            dataLogger.warning("Failed to format '\(milestonePercentage)' as percentage string")
            return "Unknown"
        }
        return description
    }
}

func calcPercentage(goal: String, total: String) -> Double? {
    guard let goal = Double(goal) else {
        return nil
    }
    guard let total = Double(total) else {
        return nil
    }
    return total/goal
}

extension TiltifyWidgetData: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case totalRaisedRaw
        case goalRaw
        case milestones
        case currencyCode
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Self.CodingKeys)
        self.name = try container.decode(String.self, forKey: .name)
        self.totalRaisedRaw = try container.decode(String.self, forKey: .totalRaisedRaw)
        self.goalRaw = try container.decode(String.self, forKey: .goalRaw)
        self.milestones = try container.decode([TiltifyMilestone].self, forKey: .milestones)
        self.currencyCode = try container.decode(String.self, forKey: .currencyCode)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        self.currencyFormatter = formatter
        if let totalRaised = Double(self.totalRaisedRaw) {
            self.previousMilestone = Self.previousMilestone(at: totalRaised, in: self.milestones)
            self.nextMilestone = Self.nextMilestone(at: totalRaised, in: self.milestones)
            self.futureMilestones = Self.futureMilestones(at: totalRaised, in: self.milestones)
        } else {
            self.previousMilestone = nil
            self.nextMilestone = nil
            self.futureMilestones = []
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Self.CodingKeys)
        try container.encode(name, forKey: .name)
        try container.encode(totalRaisedRaw, forKey: .totalRaisedRaw)
        try container.encode(goalRaw, forKey: .goalRaw)
        try container.encode(milestones, forKey: .milestones)
        try container.encode(currencyCode, forKey: .currencyCode)
    }
}
