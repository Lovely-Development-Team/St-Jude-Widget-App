//
//  INRewardExtension.swift
//  Intents Extension
//
//  Created by Ben Cardy on 07/09/2022.
//

import Foundation

extension ShortcutReward {
    convenience init(from reward: TiltifyCampaignReward, showFullCurrencySymbol: Bool) {
        let (decimalValue, amountString) = formatCurrency(from: Double(reward.amount.value ?? "0") ?? 0, currency: reward.amount.currency, showFullCurrencySymbol: showFullCurrencySymbol)
        self.init(identifier: reward.publicId.uuidString, display: reward.name, subtitle: amountString, image: nil)
        self.name = reward.name
        self.rewardDescription = reward.description
        self.stringAmountValue = reward.amount.value
        self.decimalAmountValue = decimalValue
        self.currency = reward.amount.currency
    }
}
