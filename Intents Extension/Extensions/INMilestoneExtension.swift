//
//  INMilestoneExtension.swift
//  INMilestoneExtension
//
//  Created by David on 25/08/2021.
//

import Foundation

extension INMilestone {
    convenience init(from milestone: TiltifyMilestone, showFullCurrencySymbol: Bool) {
        let (decimalValue, amountString) = formatCurrency(from: Double(milestone.amount.value ?? "0") ?? 0, currency: milestone.amount.currency, showFullCurrencySymbol: showFullCurrencySymbol)
        self.init(identifier: String(milestone.id), display: milestone.name, subtitle: amountString, image: nil)
        self.name = milestone.name
        self.stringAmountValue = milestone.amount.value
        self.decimalAmountValue = decimalValue
        self.currency = milestone.amount.currency
    }
    
    convenience init(from milestone: Milestone, showFullCurrencySymbol: Bool) {
        let (decimalValue, amountString) = formatCurrency(from: milestone.amount.value, currency: milestone.amount.currency, showFullCurrencySymbol: showFullCurrencySymbol)
        self.init(identifier: String(milestone.id), display: milestone.name, subtitle: amountString, image: nil)
        self.name = milestone.name
        self.stringAmountValue = "\(milestone.amount.value)"
        self.decimalAmountValue = decimalValue
        self.currency = milestone.amount.currency
    }
}
