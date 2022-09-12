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
    
    private var modifyingPublishers: Bool = false
    
    init(id: UUID) {
        self.showMilestones = false
        self.showGoal = false
        self.showSignificantAmounts = false
        self.showMilestoneAdded = false
        
        self.enableCustomAmountNotification = false
        if(self.enableCustomAmountNotification) {
            self.customAmountInput = ""
        }
        
        self.setupPublishers()
        self.refresh()
    }
    
    //these four functions are for the new input system. it formats the amount with thousands separators and stuff once you're done editing, and when editing it just has the digits so the commas don't mess anything up with your input
    func formatText() {
        guard let number = self.getNumberFromFormattedString(self.customAmountInput) else { return }
        guard let string = self.getFormattedStringFromNumber(number) else { return }
        self.customAmountInput = string
    }
    
    func deformatText() {
        guard let number = self.getNumberFromFormattedString(self.customAmountInput) else { return }
        self.customAmountInput = number.stringValue
    }
    
    func getFormattedStringFromNumber(_ number: NSNumber) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = ""
        formatter.currencySymbol = ""
        
        return formatter.string(from: number)
    }
    
    func getNumberFromFormattedString(_ string: String) -> NSNumber? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        return formatter.number(from: string)
    }
    
    func setupPublishers() {
        self.modifyingPublishers = true
        self.$showMilestones.removeDuplicates().sink { newValue in
            if(!self.refreshing && !self.modifyingPublishers) { UserDefaults.shared.showMilestoneNotification = newValue }
        }.store(in: &self.subscribers)
        
        self.$showGoal.removeDuplicates().sink { newValue in
            if(!self.refreshing && !self.modifyingPublishers) { UserDefaults.shared.showGoalNotification = newValue }
        }.store(in: &self.subscribers)
        
        
        self.$showSignificantAmounts.removeDuplicates().sink { newValue in
            if(!self.refreshing && !self.modifyingPublishers) { UserDefaults.shared.showSignificantAmountNotification = newValue }
        }.store(in: &self.subscribers)
        
        
        self.$showMilestoneAdded.removeDuplicates().sink { newValue in
            if(!self.refreshing && !self.modifyingPublishers) { UserDefaults.shared.showMilestoneAddedNotification = newValue }
        }.store(in: &self.subscribers)
        
        self.$enableCustomAmountNotification.removeDuplicates().sink { newValue in
            if(!self.refreshing && !self.modifyingPublishers) { UserDefaults.shared.enableCustomAmountNotification = newValue }
        }.store(in: &self.subscribers)
        
        
        self.$customAmountInput.sink(receiveValue: {newValue in
            if !self.refreshing, 
            !self.modifyingPublishers {
                if let numberValue = self.getNumberFromFormattedString(newValue) {
                    //no currency formatting fallback (e.g. 300000)
                    UserDefaults.shared.customNotificationAmount = numberValue.doubleValue
                    self.rejectedInputShowing = false
                } else {
                    self.rejectedInputShowing = true
                }
            }
        }).store(in: &self.subscribers)
        
        
        self.$enableCustomAmountNotification.sink(receiveValue: {newValue in
            if(!self.refreshing && !self.modifyingPublishers) {
                UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {(settings) in
                    switch(settings.authorizationStatus) {
                    case .authorized:
                        DispatchQueue.main.async {
                            if(newValue) {
                                print(UserDefaults.shared.customNotificationAmount)
                                if(UserDefaults.shared.customNotificationAmount != 0.0) {
                                    self.customAmountInput = self.getFormattedStringFromNumber(NSNumber(value: UserDefaults.shared.customNotificationAmount)) ?? "100.00"
                                }
                            }
                        }
                        break
                    default:
                        setNotificationPreference(newValue: nil, for: nil)
                        break
                    }
                })
            }
        }).store(in: &self.subscribers)
        self.modifyingPublishers = false
    }
    
    func removePublishers() {
        self.modifyingPublishers = true
        self.subscribers = []
        self.modifyingPublishers = false
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
                        self.enableCustomAmountNotification = UserDefaults.shared.enableCustomAmountNotification
                        if self.enableCustomAmountNotification {
                            if UserDefaults.shared.customNotificationAmount != 0 {
                                self.customAmountInput = self.getFormattedStringFromNumber(NSNumber(value: UserDefaults.shared.customNotificationAmount)) ?? "100.00"
                            }
                        }
                        self.notificationsAllowed = true
                    } else if settings.authorizationStatus == .denied {
                        self.removePublishers()
                        self.showMilestones = false
                        self.showGoal = false
                        self.showSignificantAmounts = false
                        self.showMilestoneAdded = false
                        self.notificationsAllowed = false
                        self.enableCustomAmountNotification = false
                        self.customAmountInput = "100.00"
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
