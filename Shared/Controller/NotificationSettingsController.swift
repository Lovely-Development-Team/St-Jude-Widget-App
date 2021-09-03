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
    
    @Published var enableCustomAmountNotification: Bool = false
    @Published var customAmountInput: String = "$100"
    @Published var rejectedInputShowing: Bool = false
    
    init() {
        self.showMilestones = UserDefaults.shared.showMilestoneNotification
        self.showGoal = UserDefaults.shared.showGoalNotification
        self.showSignificantAmounts = UserDefaults.shared.showSignificantAmountNotification
        self.showMilestoneAdded = UserDefaults.shared.showMilestoneAddedNotification
        
        self.enableCustomAmountNotification = (UserDefaults.shared.double(forKey: "customNotificationAmount") != 0)
        if(self.enableCustomAmountNotification) {
            self.customAmountInput = formatCurrency(from: String(UserDefaults.shared.double(forKey: "customNotificationAmount")), currency: "USD", showFullCurrencySymbol: false).1
        }
        
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
        
        
        self.$customAmountInput.sink(receiveValue: {newValue in
            if let doubleValue = Double(newValue) {
                //no currency formatting fallback (e.g. 300000)
                UserDefaults.shared.set(doubleValue, forKey: "customNotificationAmount")
                self.rejectedInputShowing = false
            } else {
                //currency formatter (e.g. $300,000)
                let f = NumberFormatter()
                f.numberStyle = .currency
                if let number = f.number(from: newValue) {
                    DispatchQueue.main.async {
                        self.rejectedInputShowing = false
                        UserDefaults.shared.set(number.doubleValue, forKey: "customNotificationAmount")
                    }
                } else {
                    self.rejectedInputShowing = true
                }
            }
        }).store(in: &self.subscribers)
        
        
        self.$enableCustomAmountNotification.sink(receiveValue: {newValue in
            UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {(settings) in
                switch(settings.authorizationStatus) {
                case .authorized:
                    DispatchQueue.main.async {
                        if(newValue) {
                            if(UserDefaults.shared.double(forKey: "customNotificationAmount") == 0.0) {
                                self.customAmountInput = "$100.00"
                                UserDefaults.shared.set(100, forKey: "customNotificationAmount")
                            } else {
                                self.customAmountInput = formatCurrency(from: String(UserDefaults.shared.double(forKey: "customNotificationAmount")), currency: "USD", showFullCurrencySymbol: false).1
                            }
                        } else {
                            UserDefaults.shared.set(nil, forKey: "customNotificationAmount")
                        }
                    }
                    break
                default:
                    setNotificationPreference(newValue: nil, for: nil)
                    break
                }
            })
        }).store(in: &self.subscribers)
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
                        self.enableCustomAmountNotification = (UserDefaults.shared.double(forKey: "customNotificationAmount") != 0)
                        if(self.enableCustomAmountNotification) {
                            self.customAmountInput = formatCurrency(from: String(UserDefaults.shared.double(forKey: "customNotificationAmount")), currency: "USD", showFullCurrencySymbol: false).1
                        }
                        self.notificationsAllowed = true
                    } else {
                        self.removePublishers()
                        self.showMilestones = false
                        self.showGoal = false
                        self.showSignificantAmounts = false
                        self.showMilestoneAdded = false
                        self.notificationsAllowed = false
                        self.enableCustomAmountNotification = false
                        self.customAmountInput = "$100"
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
