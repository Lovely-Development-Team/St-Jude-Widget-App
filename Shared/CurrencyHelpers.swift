//
//  CurrencyHelpers.swift
//  CurrencyHelpers
//
//  Created by David on 25/08/2021.
//

import Foundation

func formatCurrency(from string: Double, currency currencyCode: String, showFullCurrencySymbol: Bool) -> (NSNumber?, String) {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currencyCode
    formatter.currencySymbol = "USD"
    if !showFullCurrencySymbol {
        formatter.currencySymbol = "$"
    }
    let decimalValue = NSNumber(value: string)
    let displayString = formatter.string(from: decimalValue) ?? "Unknown"
    return (decimalValue, displayString)
}

func formatCurrency(amount: ResolvedTiltifyAmount, showFullCurrencySymbol: Bool) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = amount.currency
    formatter.currencySymbol = "USD"
    if !showFullCurrencySymbol {
        formatter.currencySymbol = "$"
    }
    let decimalValue = NSNumber(value: amount.value)
    let displayString = formatter.string(from: decimalValue) ?? "Unknown"
    return displayString
}
