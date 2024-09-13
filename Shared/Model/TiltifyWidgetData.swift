//
//  TiltifyWidgetData.swift
//  TiltifyWidgetData
//
//  Created by David on 23/08/2021.
//

import Foundation

let RELAY_FUNDRAISER_ID = UUID(uuidString: "8A17EE82-B90A-4ABA-A22F-E8CC7E8CF410")!

struct TiltifyWidgetData: Equatable {
    let id: UUID
    let name: String
    let username: String?
    let description: String
    private let totalRaisedRaw: String
    var totalRaised: Double? {
        Double(totalRaisedRaw)
    }
    var totalRaisedNumerical: Double {
        totalRaised ?? 0
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
    func goalDescription(showFullCurrencySymbol: Bool, trimDecimalPlaces: Bool = false) -> String {
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
        
        if trimDecimalPlaces && descriptionString.hasSuffix("00") {
            return String(descriptionString.dropLast(3))
        }
        
        return descriptionString
    }
    let milestones: [Milestone]
    let previousMilestone: Milestone?
    let nextMilestone: Milestone?
    let futureMilestones: [Milestone]
    
    let avatarImageData: Data?
    
    let rewards: [Reward]
    
    private let currencyCode: String
    let currencyFormatter: NumberFormatter
    let percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.roundingMode = .down
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    let shortPercentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.roundingMode = .down
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    var multiplier: Int {
        if(self.totalRaisedNumerical <= self.goal ?? 1) {
            return 1
        }
        return Int(floor(self.totalRaisedNumerical/(self.goal ?? 1)))+1
    }
    
    var progressBarAmount: Double? {
        if(self.totalRaisedNumerical <= self.goal ?? 1) {
            return self.percentageReached
        }
        return (self.totalRaisedNumerical.truncatingRemainder(dividingBy: (self.goal ?? 1)))/(self.goal ?? 1)
    }
    
    init(from campaign: TiltifyCampaign) {
        self.id = campaign.publicId
        self.name = campaign.title
        self.description = campaign.description
        self.currencyCode = campaign.totalAmountRaised.currency
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        currencyFormatter = formatter
        self.totalRaisedRaw = campaign.totalAmountRaised.value ?? "0"
        self.goalRaw = campaign.goal.value ?? "0"
        self.milestones = campaign.milestones.sorted(by: sortMilestones).map { Milestone(from: $0, campaignId: campaign.publicId) }
        if let value = campaign.totalAmountRaised.value, let totalRaised = Double(value) {
            self.previousMilestone = Self.previousMilestone(at: totalRaised, in: self.milestones)
            self.nextMilestone = Self.nextMilestone(at: totalRaised, in: self.milestones)
            self.futureMilestones = Self.futureMilestones(at: totalRaised, in: self.milestones)
        } else {
            self.previousMilestone = nil
            self.nextMilestone = nil
            self.futureMilestones = []
        }
        self.rewards = campaign.rewards.map { Reward(from: $0, campaignId: campaign.publicId) }
        self.username = campaign.user.username
        
        do {
            if let src = campaign.avatar?.src, let url = URL(string: src) {
                self.avatarImageData = try Data(contentsOf: url)
            } else {
                self.avatarImageData = nil
            }
        } catch {
            dataLogger.debug("Could not get avatar image data: \(error)")
            self.avatarImageData = nil
        }
    }
    
    init(from campaign: Campaign) async throws {
        self.id = campaign.id
        self.name = campaign.title
        self.description = campaign.description ?? ""
        self.currencyCode = campaign.totalRaised.currency
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        currencyFormatter = formatter
        self.totalRaisedRaw = campaign.totalRaised.value ?? "0"
        self.goalRaw = campaign.goal.value ?? "0"
        self.milestones = try await AppDatabase.shared.fetchSortedMilestones(for: campaign)
        if let value = campaign.totalRaised.value, let totalRaised = Double(value) {
            self.previousMilestone = Self.previousMilestone(at: totalRaised, in: self.milestones)
            self.nextMilestone = Self.nextMilestone(at: totalRaised, in: self.milestones)
            self.futureMilestones = Self.futureMilestones(at: totalRaised, in: self.milestones)
        } else {
            self.previousMilestone = nil
            self.nextMilestone = nil
            self.futureMilestones = []
        }
        self.rewards = try await AppDatabase.shared.fetchSortedRewards(for: campaign)
        self.avatarImageData = nil
        self.username = campaign.user.username
    }
           
    init(from teamEvent: TeamEvent) async {
        self.id = teamEvent.id
        self.name = teamEvent.name
        self.description = teamEvent.description
        self.currencyCode = teamEvent.totalRaised.currency
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        currencyFormatter = formatter
        self.totalRaisedRaw = teamEvent.totalRaised.value ?? "0"
        self.goalRaw = teamEvent.goal.value ?? "0"
        do {
            self.milestones = try await AppDatabase.shared.fetchSortedMilestones(for: teamEvent)
        } catch {
            dataLogger.notice("Failed to fetch milestones: \(error.localizedDescription)")
            self.milestones = []
        }
        self.previousMilestone = Self.previousMilestone(at: teamEvent.totalRaised.numericalValue, in: self.milestones)
        self.nextMilestone = Self.nextMilestone(at: teamEvent.totalRaised.numericalValue, in: self.milestones)
        self.futureMilestones = Self.futureMilestones(at: teamEvent.totalRaised.numericalValue, in: self.milestones)
        self.rewards = []
        self.avatarImageData = nil
        self.username = nil
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
    var shortPercentageReachedDescription: String? {
        guard let percentageReached = percentageReached else {
            return nil
        }
        return shortPercentageFormatter.string(from: percentageReached as NSNumber)
    }
    
    static func previousMilestone(at totalRaised: Double, in milestones: [Milestone]) -> Milestone? {
        return milestones.last { milestone in
            return milestone.amount.value < totalRaised
        }
    }
    
    static func nextMilestone(at totalRaised: Double, in milestones: [Milestone]) -> Milestone? {
        return milestones.first { milestone in
            return milestone.amount.value >= totalRaised
        }
    }
    
    static func futureMilestones(at totalRaised: Double, in milestones: [Milestone]) -> [Milestone] {
        return milestones.filter { milestone in
            return milestone.amount.value >= totalRaised
        }
    }
    
    func percentage(ofMilestone milestone: Milestone) -> Double? {
        guard let totalRaised = totalRaised else {
            return nil
        }
        return totalRaised/milestone.amount.value
    }
    
    func percentageDescription(for milestone: Milestone) -> String {
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
    
    func raisedShortRepresentation(showFullCurrencySymbol: Bool = false) -> String {
        guard let totalRaised = totalRaised else {
            return "?"
        }
        
        let originalSymbol = currencyFormatter.currencySymbol
        let originalCode = currencyFormatter.currencyCode
        currencyFormatter.currencyCode = "USD"
        
        if !showFullCurrencySymbol {
            currencyFormatter.currencySymbol = "$"
        } else {
            currencyFormatter.currencySymbol = ""
        }
        
        let result: String
        
        if totalRaised < 1000 {
            result = currencyFormatter.string(from: totalRaised as NSNumber) ?? "?"
        } else if totalRaised < 1000000 {
            currencyFormatter.maximumFractionDigits = 1
            let newNumber = currencyFormatter.string(from: (totalRaised / 1000) as NSNumber) ?? "?"
            result = "\(newNumber)k"
        } else {
            currencyFormatter.maximumFractionDigits = 1
            let newNumber = currencyFormatter.string(from: (totalRaised / 1000000) as NSNumber) ?? "?"
            result = "\(newNumber)m"
        }
        
        currencyFormatter.currencySymbol = originalSymbol
        currencyFormatter.currencyCode = originalCode
        return result
    }
    
    var widgetURL: String {
        "relay-fm-for-st-jude://campaign?id=\(id)"
    }
    
}

func calcPercentage(goal: String, total: String) -> Double? {
    guard let goal = Double(goal), goal != 0 else {
        return nil
    }
    guard let total = Double(total) else {
        return nil
    }
    return total/goal
}

extension TiltifyWidgetData: Codable {
    enum CodingKeys: String, CodingKey {
        case publicId
        case name
        case totalRaisedRaw
        case goalRaw
        case milestones
        case currencyCode
        case description
        case rewards
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Self.CodingKeys)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.totalRaisedRaw = try container.decode(String.self, forKey: .totalRaisedRaw)
        self.goalRaw = try container.decode(String.self, forKey: .goalRaw)
        self.milestones = try container.decode([Milestone].self, forKey: .milestones)
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
        self.rewards = try container.decode([Reward].self, forKey: .rewards)
        self.id = try container.decode(UUID.self, forKey: .publicId)
        self.avatarImageData = nil
        self.username = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Self.CodingKeys)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(totalRaisedRaw, forKey: .totalRaisedRaw)
        try container.encode(goalRaw, forKey: .goalRaw)
        try container.encode(milestones, forKey: .milestones)
        try container.encode(currencyCode, forKey: .currencyCode)
        try container.encode(id, forKey: .publicId)
    }
}
