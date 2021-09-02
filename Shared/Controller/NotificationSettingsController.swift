//
//  NotificationSettingsController.swift
//  NotificationSettingsController
//
//  Created by David on 02/09/2021.
//

import Foundation
import UserNotifications
import Combine

class NotificationSettingsController: ObservableObject {

    private var refreshing = false
    private var subscribers: Set<AnyCancellable> = []
    
    @Published var showMilestones: Bool = false
    
    @Published var showGoal: Bool = false
    
    @Published var showSignificantAmounts: Bool = false
    
    @Published var showMilestoneAdded: Bool = false
    
    @Published var notificationsAllowed: Bool = false
    @Published var notificationAccessAsked: Bool = false
    
    init() {
        self.showMilestones = UserDefaults.shared.showMilestoneNotification
        self.showGoal = UserDefaults.shared.showGoalNotification
        self.showSignificantAmounts = UserDefaults.shared.showSignificantAmountNotification
        self.showMilestoneAdded = UserDefaults.shared.showMilestoneAddedNotification
        self.setupPublishers()
        self.refresh()
    }
    
    func setupPublishers() {
        self.$showMilestones.removeDuplicates().sink { newValue in
            if(!self.refreshing) { UserDefaults.shared.showMilestoneNotification = newValue }
        }.store(in: &self.subscribers)
        
        
        self.$showGoal.removeDuplicates().sink { newValue in
            if(!self.refreshing) { UserDefaults.shared.showGoalNotification = newValue }
        }.store(in: &self.subscribers)
        
        
        self.$showSignificantAmounts.removeDuplicates().sink { newValue in
            if(!self.refreshing) { UserDefaults.shared.showSignificantAmountNotification = newValue }
        }.store(in: &self.subscribers)
        
        
        self.$showMilestoneAdded.removeDuplicates().sink { newValue in
            if(!self.refreshing) { UserDefaults.shared.showMilestoneAddedNotification = newValue }
        }.store(in: &self.subscribers)
    }
    
    func removePublishers() {
        self.subscribers = []
    }
    
    func refresh() {
        if (!self.refreshing) {
            self.refreshing = true
            UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {(settings) in
                
                DispatchQueue.main.async {
                    if(settings.authorizationStatus == .authorized) {
                        self.setupPublishers()
                        self.showMilestones = UserDefaults.shared.showMilestoneNotification
                        self.showGoal = UserDefaults.shared.showGoalNotification
                        self.showSignificantAmounts = UserDefaults.shared.showSignificantAmountNotification
                        self.showMilestoneAdded = UserDefaults.shared.showMilestoneAddedNotification
                        self.notificationsAllowed = true
                    } else {
                        self.removePublishers()
                        self.showMilestones = false
                        self.showGoal = false
                        self.showSignificantAmounts = false
                        self.showMilestoneAdded = false
                        self.notificationsAllowed = false
                    }
                    
                    if(settings.authorizationStatus != .notDetermined) {
                        self.notificationAccessAsked = true
                    }
                    
                    self.refreshing = false
                }
            })
        }
    }
}
