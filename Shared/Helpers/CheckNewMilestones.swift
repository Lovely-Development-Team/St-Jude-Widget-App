//
//  CheckNewMilestones.swift
//  CheckNewMilestones
//
//  Created by Justin Hamilton on 8/31/21.
//

import Foundation

func checkNewMilestones(for widgetData: TiltifyWidgetData) {
    if(!UserDefaults.shared.showMilestoneAddedNotification) { return }
    
    let cachedMilestoneIDs = UserDefaults.shared.object(forKey: "cachedMilestoneIDs") as? [UUID] ?? []
    
    let currentIDs = (widgetData.milestones.map({$0.id}))
    
    if(cachedMilestoneIDs.count < currentIDs.count && !cachedMilestoneIDs.isEmpty) {
        let newMilestoneIDs = currentIDs.filter({!cachedMilestoneIDs.contains($0)})
        let newMilestones = widgetData.milestones.filter({newMilestoneIDs.contains($0.id)})
        
        var title = "Milestone Added"
        var message = "\(newMilestones.first!.name): \(formatCurrency(amount: newMilestones.first!.amount, showFullCurrencySymbol: UserDefaults.shared.inAppShowFullCurrencySymbol))"
        
        if(newMilestones.count > 1) {
            title = "Milestones Added"
            for milestone in newMilestones.dropFirst() {
                message.append("\n\(milestone.name): \(formatCurrency(amount: milestone.amount, showFullCurrencySymbol: UserDefaults.shared.inAppShowFullCurrencySymbol))")
            }
        }
        
        sendNotification(title, message: message)
    }
    
    UserDefaults.shared.set(currentIDs, forKey: "cachedMilestoneIDs")
}
