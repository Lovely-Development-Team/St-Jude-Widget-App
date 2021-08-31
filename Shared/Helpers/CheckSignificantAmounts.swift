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
    
    if(cachedTotal != -1 && cachedTotal != totalRaised) {
        var milestoneAmount: Double = -1.0
        if let previousMilestone = widgetData.previousMilestone {
            milestoneAmount = Double(previousMilestone.amount.value) ?? -1.0
        }
        
        if(cachedTotal < milestoneAmount && totalRaised > milestoneAmount) {
            showMilestoneNotification = true
        }
        
        let nearest50kToTotalRaised = Double(Int((totalRaised+50000)/50000))*50000
        let nearest50kToCachedTotal = Double(Int((cachedTotal+50000)/50000))*50000
        
        if(nearest50kToTotalRaised > nearest50kToCachedTotal) {
            showAmountNotification = true
        }
        
        if(cachedTotal < goal && totalRaised > goal) {
            showGoalNotification = true
        }
        
        let nearestGoalMultipleToTotalRaised = Double(Int((totalRaised+goal)/goal))*goal
        let nearestGoalMultipleToCachedTotal = Double(Int((cachedTotal+goal)/goal))*goal
        
        if(nearestGoalMultipleToTotalRaised > nearestGoalMultipleToCachedTotal && !showGoalNotification) {
            showGoalMultiplierNotification = true
        }
    }
    
    print("===")
    print("cached total: \(cachedTotal)")
    print("new total: \(totalRaised)")
    print("===")
    
    print("show milestone: \(showMilestoneNotification)")
    print("show 50k marker: \(showAmountNotification)")
    print("show goal reached: \(showGoalNotification)")
    print("show goal multiple (2x, 3x, etc.): \(showGoalMultiplierNotification)")
    
    UserDefaults.shared.set(totalRaisedRaw, forKey: "cachedTotalRaised")
}
