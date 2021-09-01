//
//  CheckSignificantAmounts.swift
//  CheckSignificantAmounts
//
//  Created by Justin Hamilton on 8/30/21.
//

import Foundation

func checkSignificantAmounts(for widgetData: TiltifyWidgetData) {
    //check if cached amount is significant
    let cachedTotal = round((UserDefaults.shared.object(forKey: "cachedTotalRaised") as? Double) ?? -1.0)
    let totalRaisedRaw = widgetData.totalRaised ?? -1.0
    let totalRaised = round(totalRaisedRaw)
    let goal = widgetData.goal ?? -1.0
    
    var showMilestoneNotification = false
    var showAmountNotification = false
    var showGoalNotification = false
    var showGoalMultiplierNotification = false
    
    
    let nearest50kToTotalRaised = Double(Int((totalRaised+50000)/50000))*50000
    let nearest50kToCachedTotal = Double(Int((cachedTotal+50000)/50000))*50000
    
    let nearestGoalMultipleToCachedTotal = Double(Int((cachedTotal+goal)/goal))*goal
    let nearestGoalMultipleToTotalRaised = Double(Int((totalRaised+goal)/goal))*goal
    
    if(cachedTotal != -1 && cachedTotal != totalRaised) {
        var milestoneAmount: Double = -1.0
        if let previousMilestone = widgetData.previousMilestone {
            milestoneAmount = Double(previousMilestone.amount.value) ?? -1.0
        }
        
        if(cachedTotal < milestoneAmount && totalRaised > milestoneAmount) {
            showMilestoneNotification = true
        }
        
        
        if(nearest50kToTotalRaised > nearest50kToCachedTotal) {
            showAmountNotification = true
        }
        
        if(cachedTotal < goal && totalRaised > goal) {
            showGoalNotification = true
        }
        
        
        if(nearestGoalMultipleToTotalRaised > nearestGoalMultipleToCachedTotal && !showGoalNotification) {
            showGoalMultiplierNotification = true
        }
    }
    
    var notificationTitle: String = "You should not be seeing this."
    var messages: [String] = []
    
    if(showAmountNotification && UserDefaults.shared.showSignificantAmountNotification) {
        let amountString = formatCurrency(from: String(nearest50kToCachedTotal), currency: "USD", showFullCurrencySymbol: UserDefaults.shared.inAppShowFullCurrencySymbol)
        
        notificationTitle = "Significant Amount Reached"
        messages.append("Reached \(amountString.1)")
    }
    
    if(showMilestoneNotification && UserDefaults.shared.showMilestoneNotification) {
        var amountString = "Unknown Amount"
        var milestoneName = "Unknown Milestone"
        if let previousMilestone = widgetData.previousMilestone {
            amountString = formatCurrency(amount: previousMilestone.amount, showFullCurrencySymbol: UserDefaults.shared.inAppShowFullCurrencySymbol)
            milestoneName = previousMilestone.name
        }
        
        notificationTitle = "Milestone Reached"
        messages.append("Reached milestone \"\(milestoneName)\" at \(amountString)")
    }
    
    if(showGoalNotification && UserDefaults.shared.showGoalNotification) {
        let amountString = widgetData.goalDescription(showFullCurrencySymbol: UserDefaults.shared.inAppShowFullCurrencySymbol)
        notificationTitle = "🎉 Campaign Goal Reached 🎉"
        messages.append("Reached campaign goal of \(amountString)")
    }
    
    if(showGoalMultiplierNotification && UserDefaults.shared.showSignificantAmountNotification) {
        notificationTitle = "Significant Amount Reached"
        
        let multiple = Int(nearestGoalMultipleToCachedTotal/goal)
        let amountString = formatCurrency(from: String(nearestGoalMultipleToCachedTotal), currency: "USD", showFullCurrencySymbol: UserDefaults.shared.inAppShowFullCurrencySymbol)
        
        messages.append("Reached \(Int(multiple))x campaign goal at \(amountString.1)")
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
