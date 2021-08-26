//
//  INAmountExtension.swift
//  INAmountExtension
//
//  Created by David on 25/08/2021.
//

import Foundation

extension INAmount {
    convenience init(from amount: TiltifyAmount, showFullCurrencySymbol: Bool) {
        let (decimalValue, displayString) = formatCurrency(from: amount.value, currency: amount.currency, showFullCurrencySymbol: showFullCurrencySymbol)
        self.init(identifier: nil, display: displayString)
        self.stringValue = amount.value
        self.decimalValue = decimalValue
        self.currency = amount.currency
    }
}
