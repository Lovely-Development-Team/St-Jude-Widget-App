//
//  CurrencyHelpers.swift
//  CurrencyHelpers
//
//  Created by David on 25/08/2021.
//

import Foundation

func formatCurrency(from string: String, currency currencyCode: String, showFullCurrencySymbol: Bool) -> (NSNumber?, String) {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currencyCode
    formatter.currencySymbol = "USD"
    if !showFullCurrencySymbol {
        formatter.currencySymbol = "$"
    }
    let decimalValue = Double(string).map { NSNumber(value: $0) }
    let displayString = decimalValue.flatMap { formatter.string(from: $0) } ?? "Unknown"
    return (decimalValue, displayString)
}

func formatCurrency(amount: TiltifyAmount, showFullCurrencySymbol: Bool) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = amount.currency
    formatter.currencySymbol = "USD"
    if !showFullCurrencySymbol {
        formatter.currencySymbol = "$"
    }
    let decimalValue = Double(amount.value).map { NSNumber(value: $0) }
    let displayString = decimalValue.flatMap { formatter.string(from: $0) } ?? "Unknown"
    return displayString
}
