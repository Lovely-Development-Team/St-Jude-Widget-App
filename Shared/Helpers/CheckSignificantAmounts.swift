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
//    UserDefaults.shared.set(300000.0, forKey: "cachedTotalRaised")
    let cachedTotalRaw = (UserDefaults.shared.object(forKey: "cachedTotalRaised") as? Double) ?? -1.0
    let cachedTotal = round(cachedTotalRaw)
    
    
    let totalRaisedRaw = widgetData.totalRaised ?? -1.0
    //uncomment below for testing
//    let totalRaisedRaw = 300001.0
    let totalRaised = round(totalRaisedRaw)
    let goal = widgetData.goal ?? -1.0
    
    let customAmount = (UserDefaults.shared.object(forKey: "customNotificationAmount") as? Double) ?? -1.0
    
    var shouldShowMilestoneNotification = false
    var shouldShowAmountNotification = false
    var shouldShowGoalNotification = false
    var shouldShowGoalMultiplierNotification = false
    var shouldShowCustomAmountNotification = false
    
    
    //rounded cached total and total raised are only used for these 4 calculations, decimals would give weird values. "raw" values are used for the rest
    let nearest50kToTotalRaised = Double(Int((totalRaised+50000)/50000))*50000
    let nearest50kToCachedTotal = Double(Int((cachedTotal+50000)/50000))*50000
    
    let nearestGoalMultipleToCachedTotal = Double(Int((cachedTotal+goal)/goal))*goal
    let nearestGoalMultipleToTotalRaised = Double(Int((totalRaised+goal)/goal))*goal
    
    if(cachedTotalRaw != -1 && cachedTotalRaw != totalRaisedRaw) {
        var milestoneAmount: Double = -1.0
        if let previousMilestone = widgetData.previousMilestone {
            milestoneAmount = Double(previousMilestone.amount.value) ?? -1.0
        }
        
        if(cachedTotalRaw < milestoneAmount && totalRaisedRaw > milestoneAmount) {
            shouldShowMilestoneNotification = true
        }
        
        
        if(nearest50kToTotalRaised > nearest50kToCachedTotal) {
            shouldShowAmountNotification = true
        }
        
        if(cachedTotalRaw < goal && totalRaisedRaw > goal) {
            shouldShowGoalNotification = true
        }
        
        
        if(nearestGoalMultipleToTotalRaised > nearestGoalMultipleToCachedTotal && !shouldShowGoalNotification) {
            shouldShowGoalMultiplierNotification = true
        }
        
        if(customAmount != -1.0) {
            if(cachedTotalRaw < customAmount && totalRaisedRaw > customAmount) {
                shouldShowCustomAmountNotification = true
            }
        }
    }
    
    var notificationTitle: String = "You should not be seeing this."
    var messages: [String] = []
    
    if(shouldShowAmountNotification && UserDefaults.shared.showSignificantAmountNotification) {
        let amountString = formatCurrency(from: String(nearest50kToCachedTotal), currency: "USD", showFullCurrencySymbol: UserDefaults.shared.inAppShowFullCurrencySymbol)
        
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
        let amountString = formatCurrency(from: String(nearestGoalMultipleToCachedTotal), currency: "USD", showFullCurrencySymbol: UserDefaults.shared.inAppShowFullCurrencySymbol)
        
        messages.append("Reached \(Int(multiple))x campaign goal at \(amountString.1)")
    }
    
    if(shouldShowCustomAmountNotification) {
        notificationTitle = "Custom Amount Reached"
        let amountString = formatCurrency(from: String(customAmount), currency: "USD", showFullCurrencySymbol: UserDefaults.shared.inAppShowFullCurrencySymbol)
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
    
    UserDefaults.shared.set(totalRaisedRaw, forKey: "cachedTotalRaised")
}
