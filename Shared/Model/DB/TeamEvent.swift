//
//  TeamEvent.swift
//  St Jude
//
//  Created by Ben Cardy on 03/08/2023.
//

import Foundation

import GRDB

/// The Campaign struct.
struct TeamEvent: Identifiable, Hashable {
    /// The campaign publicId
    var id: UUID { publicId }
    var publicId: UUID
    let name: String
    let description: String
    private let goalCurrency: String
    private let goalValue: String?
    var goal: TiltifyAmount {
        TiltifyAmount(currency: goalCurrency, value: goalValue)
    }
    let goalNumericalValue: Double?
    var goalNumerical: Double {
        goalNumericalValue ?? 0
    }
    func goalDescription(showFullCurrencySymbol: Bool) -> String {
        currencyDescription(showFullCurrencySymbol: showFullCurrencySymbol, value: goalNumerical, currency: goalCurrency)
    }
    private let totalRaisedCurrency: String
    private let totalRaisedValue: String?
    var totalRaised: TiltifyAmount {
        TiltifyAmount(currency: totalRaisedCurrency, value: totalRaisedValue)
    }
    let totalRaisedNumericalValue: Double?
    var totalRaisedNumerical: Double {
        totalRaisedNumericalValue ?? 0
    }
    func totalRaisedDescription(showFullCurrencySymbol: Bool) -> String {
        currencyDescription(showFullCurrencySymbol: showFullCurrencySymbol, value: totalRaisedNumerical, currency: totalRaisedCurrency)
    }
    
    var percentageReached: Double? {
        return calcPercentage(goal: goal.value ?? "0", total: totalRaised.value ?? "0")
    }
    
    var multiplier: Int {
        if(self.totalRaisedNumerical <= self.goalNumerical) {
            return 1
        }
        return Int(floor(self.totalRaisedNumerical/self.goalNumerical))+1
    }
    
    var percentageReachedDescription: String? {
        guard let percentageReached = percentageReached else {
            return nil
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.roundingMode = .down
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter.string(from: percentageReached as NSNumber)
    }
    
    var amountRemainingDescription: String {
        let value = max(goalNumerical - totalRaisedNumerical, 0)
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = goal.currency
        currencyFormatter.currencySymbol = "$"
        let descriptionString = currencyFormatter.string(from: value as NSNumber) ?? "\(goal.currency) 0"
        return descriptionString
    }
    
    private func currencyDescription(showFullCurrencySymbol: Bool, value: Double, currency: String) -> String {
        
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

extension TeamEvent: Codable, FetchableRecord, MutablePersistableRecord {
    fileprivate enum Columns {
        static let publicId = Column(CodingKeys.publicId)
        static let name = Column(CodingKeys.name)
        static let description = Column(CodingKeys.description)
        static let goalCurrency = Column(CodingKeys.goalCurrency)
        static let goalValue = Column(CodingKeys.goalValue)
        static let goalNumericalValue = Column(CodingKeys.goalNumericalValue)
        static let totalRaisedCurrency = Column(CodingKeys.totalRaisedCurrency)
        static let totalRaisedValue = Column(CodingKeys.totalRaisedValue)
        static let totalRaisedNumericalValue = Column(CodingKeys.totalRaisedNumericalValue)
    }
    
    static let milestones = hasMany(Milestone.self)
    var milestones: QueryInterfaceRequest<Milestone> {
        request(for: TeamEvent.milestones)
    }
    
    static let rewards = hasMany(Reward.self)
    var rewards: QueryInterfaceRequest<Reward> {
        request(for: TeamEvent.rewards)
    }
}

extension TeamEvent {
    init(from apiData: TiltifyTeamEvent) {
        self.publicId = apiData.publicId
        self.name = apiData.name
        self.totalRaisedCurrency = apiData.totalAmountRaised.currency
        self.totalRaisedValue = apiData.totalAmountRaised.value
        self.totalRaisedNumericalValue = apiData.totalAmountRaised.numericalValue
        self.description = apiData.description
        self.goalCurrency = apiData.goal.currency
        self.goalValue = apiData.goal.value
        self.goalNumericalValue = apiData.goal.numericalValue
    }
    
    init(from apiData: TiltifyResponse2025) {
        self.publicId = apiData.data.fact.id
        self.name = apiData.data.fact.name
        self.totalRaisedCurrency = apiData.data.fact.totalAmountRaised.currency
        self.totalRaisedValue = apiData.data.fact.totalAmountRaised.value
        self.totalRaisedNumericalValue = apiData.data.fact.totalAmountRaised.numericalValue
        self.description = apiData.data.fact.description
        self.goalCurrency = apiData.data.fact.goal.currency
        self.goalValue = apiData.data.fact.goal.value
        self.goalNumericalValue = apiData.data.fact.goal.numericalValue
    }
    
}
