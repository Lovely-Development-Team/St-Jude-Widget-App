//
//  CheckSignificantAmounts.swift
//  CheckSignificantAmounts
//
//  Created by Justin Hamilton on 8/30/21.
//

import Foundation

func checkSignificantAmounts(for widgetData: TiltifyWidgetData) {
    //check if cached amount is significant
    //uncomment below for testing
//    UserDefaults.shared.set(49990.0, forKey: "cachedTotalRaised")
    let cachedTotal = UserDefaults.shared.double(forKey: "cachedTotalRaised")
    
    
    let totalRaised = widgetData.totalRaised ?? -1.0
    //uncomment below for testing
//    let totalRaised = 50001.0
    let goal = widgetData.goal ?? -1.0
    
    let customAmount = UserDefaults.shared.customNotificationAmount
    
    var shouldShowMilestoneNotification = false
    var shouldShowAmountNotification = false
    var shouldShowGoalNotification = false
    var shouldShowGoalMultiplierNotification = false
    var shouldShowCustomAmountNotification = false
    
    
    //rounded cached total and total raised are only used for these 4 calculations, decimals would give weird values. "raw" values are used for the rest
    let nearest50kToTotalRaised = Double(Int((round(totalRaised)+50000)/50000))*50000
    let nearest50kToCachedTotal = Double(Int((round(cachedTotal)+50000)/50000))*50000
    
    let nearestGoalMultipleToCachedTotal = Double(Int((round(cachedTotal)+goal)/goal))*goal
    let nearestGoalMultipleToTotalRaised = Double(Int((round(totalRaised)+goal)/goal))*goal
    
    if(cachedTotal != 0 && cachedTotal != totalRaised) {
        var milestoneAmount: Double = 0
        if let previousMilestone = widgetData.previousMilestone {
            milestoneAmount = previousMilestone.amount.value
        }
        
        if(cachedTotal < milestoneAmount && totalRaised > milestoneAmount) {
            shouldShowMilestoneNotification = true
        }
        
        
        if(nearest50kToTotalRaised > nearest50kToCachedTotal) {
            shouldShowAmountNotification = true
        }
        
        if(cachedTotal < goal && totalRaised > goal) {
            shouldShowGoalNotification = true
        }
        
        
        if(nearestGoalMultipleToTotalRaised > nearestGoalMultipleToCachedTotal && !shouldShowGoalNotification) {
            shouldShowGoalMultiplierNotification = true
        }
        
        if(customAmount != 0) {
            if(cachedTotal < customAmount && totalRaised > customAmount) {
                shouldShowCustomAmountNotification = true
            }
        }
    }
    
    var notificationTitle: String = "You should not be seeing this."
    var messages: [String] = []
    
    if(shouldShowAmountNotification && UserDefaults.shared.showSignificantAmountNotification) {
        let amountString = formatCurrency(from: nearest50kToCachedTotal, currency: "USD", showFullCurrencySymbol: UserDefaults.shared.inAppShowFullCurrencySymbol)
        
        notificationTitle = "Significant Amount Reached"
        messages.append("Reached \(amountString.1)")
    }
    
    if(shouldShowMilestoneNotification && UserDefaults.shared.showMilestoneNotification) {
        var amountString = "Unknown Amount"
        var milestoneName = "Unknown Milestone"
        if let previousMilestone = widgetData.previousMilestone {
            amountString = formatCurrency(amount: previousMilestone.amount, showFullCurrencySymbol: UserDefaults.shared.inAppShowFullCurrencySymbol)
            milestoneName = previousMilestone.name
        }
        
        notificationTitle = "Milestone Reached"
        messages.append("Reached milestone \"\(milestoneName)\" at \(amountString)")
    }
    
    if(shouldShowGoalNotification && UserDefaults.shared.showGoalNotification) {
        let amountString = widgetData.goalDescription(showFullCurrencySymbol: UserDefaults.shared.inAppShowFullCurrencySymbol)
        notificationTitle = "🎉 Campaign Goal Reached 🎉"
        messages.append("Reached campaign goal of \(amountString)")
    }
    
    if(shouldShowGoalMultiplierNotification && UserDefaults.shared.showSignificantAmountNotification) {
        notificationTitle = "Significant Amount Reached"
        
        let multiple = Int(nearestGoalMultipleToCachedTotal/goal)
        let amountString = formatCurrency(from: nearestGoalMultipleToCachedTotal, currency: "USD", showFullCurrencySymbol: UserDefaults.shared.inAppShowFullCurrencySymbol)
        
        messages.append("Reached \(Int(multiple))x campaign goal at \(amountString.1)")
    }
    
    if(shouldShowCustomAmountNotification) {
        notificationTitle = "Custom Amount Reached"
        let amountString = formatCurrency(from: Double(customAmount), currency: "USD", showFullCurrencySymbol: UserDefaults.shared.inAppShowFullCurrencySymbol)
        messages.append("Reached custom amount of \(amountString.1)")
    }
    
    if(messages.count > 1) {
        notificationTitle = "Multiple Milestones Reached"
        var masterMessage = messages.first!
        for message in messages.dropFirst() {
            masterMessage.append("\n\(message)")
        }
        sendNotification(notificationTitle, message: masterMessage)
    } else if(messages.count == 1) {
        sendNotification(notificationTitle, message: messages.first!)
    }
    
    UserDefaults.shared.set(totalRaised, forKey: "cachedTotalRaised")
}
