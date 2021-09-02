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
    @Published var customAmountInput: String = ""
    
    @Published var rejectedInputShowing: Bool = false
    
    init() {
        self.refresh()
        self.setupPublishers()
    }
    
    func setupPublishers() {
        self.$showMilestones.sink { newValue in
            if(!self.refreshing) { UserDefaults.shared.showMilestoneNotification = newValue }
        }.store(in: &self.subscribers)
        
        
        self.$showGoal.sink { newValue in
            if(!self.refreshing) { UserDefaults.shared.showGoalNotification = newValue }
        }.store(in: &self.subscribers)
        
        
        self.$showSignificantAmounts.sink { newValue in
            if(!self.refreshing) { UserDefaults.shared.showSignificantAmountNotification = newValue }
        }.store(in: &self.subscribers)
        
        
        self.$showMilestoneAdded.sink { newValue in
            if(!self.refreshing) { UserDefaults.shared.showMilestoneAddedNotification = newValue }
        }.store(in: &self.subscribers)
        
        self.$customAmountInput.sink(receiveValue: {newValue in
            if let doubleValue = Double(newValue) {
                UserDefaults.shared.set(doubleValue, forKey: "customNotificationAmount")
                self.rejectedInputShowing = false
            } else {
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
                            if((UserDefaults.shared.object(forKey: "customNotificationAmount") as? Double) ?? -1.0 == -1.0) {
                                self.customAmountInput = "$100.00"
                                UserDefaults.shared.set(100, forKey: "customNotificationAmount")
                            } else {
                                self.customAmountInput = formatCurrency(from: String((UserDefaults.shared.object(forKey: "customNotificationAmount") as? Double) ?? -1.0), currency: "USD", showFullCurrencySymbol: false).1
                            }
                        } else {
                            UserDefaults.shared.set(-1, forKey: "customNotificationAmount")
                        }
                    }
                    break
                default:
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound], completionHandler: {(authorized, error) in
                        if let e = error {
                            print(e.localizedDescription)
                        }
                    })
                    break
                }
            })
        }).store(in: &self.subscribers)
    }
    
    func removePublishers() {
        for subscriber in self.subscribers {
            subscriber.cancel()
        }
    }
    
    func refresh() {
        if(!self.refreshing) {
            self.refreshing = true
            removePublishers()
            UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {(settings) in
                DispatchQueue.main.async {
                    if(settings.authorizationStatus == .authorized) {
                        self.showMilestones = UserDefaults.shared.showMilestoneNotification
                        self.showGoal = UserDefaults.shared.showGoalNotification
                        self.showSignificantAmounts = UserDefaults.shared.showSignificantAmountNotification
                        self.showMilestoneAdded = UserDefaults.shared.showMilestoneAddedNotification
                        self.notificationsAllowed = true
                    } else {
                        self.showMilestones = false
                        self.showGoal = false
                        self.showSignificantAmounts = false
                        self.showMilestoneAdded = false
                        self.notificationsAllowed = false
                    }
                    
                    if(settings.authorizationStatus != .notDetermined) {
                        self.notificationAccessAsked = true
                    }
                    
                    self.customAmountInput = formatCurrency(from: String((UserDefaults.shared.object(forKey: "customNotificationAmount") as? Double) ?? -1.0), currency: "USD", showFullCurrencySymbol: false).1
                    if((UserDefaults.shared.object(forKey: "customNotificationAmount") as? Double) ?? -1.0 != -1.0) {
                        self.enableCustomAmountNotification = true
                    }
                    
                    self.setupPublishers()
                    self.refreshing = false
                }
            })
        }
    }
}
