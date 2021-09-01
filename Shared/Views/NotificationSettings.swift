//
//  NotificationSettings.swift
//  NotificationSettings
//
//  Created by Justin Hamilton on 8/31/21.
//

import SwiftUI
import UserNotifications
import Combine

class NotificationSettingsData: ObservableObject {
    private var refreshing = false
    private var subscribers: Set<AnyCancellable> = []
    
    @Published var showMilestones: Bool = false
    
    @Published var showGoal: Bool = false
    
    @Published var showSignificantAmounts: Bool = false
    
    @Published var showMilestoneAdded: Bool = false
    
    @Published var notificationsAllowed: Bool = false
    @Published var notificationAccessAsked: Bool = false
    
    init() {
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
        
        self.refresh()
    }
    
    func refresh() {
        self.refreshing = true
        self.notificationAccessAsked = false
        self.notificationsAllowed = false
        self.showMilestones = false
        self.showGoal = false
        self.showSignificantAmounts = false
        self.showMilestoneAdded = false
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {(settings) in
            if(settings.authorizationStatus == .authorized) {
                DispatchQueue.main.async {
                    self.showMilestones = UserDefaults.shared.showMilestoneNotification
                    self.showGoal = UserDefaults.shared.showGoalNotification
                    self.showSignificantAmounts = UserDefaults.shared.showSignificantAmountNotification
                    self.showMilestoneAdded = UserDefaults.shared.showMilestoneAddedNotification
                    self.notificationsAllowed = true
                }
            }
            if(settings.authorizationStatus != .notDetermined) {
                DispatchQueue.main.async {
                    self.notificationAccessAsked = true
                }
            }
            self.refreshing = false
        })
    }
}

struct NotificationSettings: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var data = NotificationSettingsData()
    
    var onDismiss: ()->()
    
    var body: some View {
        Form {
            Section(footer: Text("Significant amount notifications fire every $50k or when the goal is doubled, tripled, etc.")) {
                Toggle(isOn: self.$data.showMilestones, label: {
                    Text("Milestones")
                })
                    .disabled(!self.data.notificationsAllowed && self.data.notificationAccessAsked)
                Toggle(isOn: self.$data.showGoal, label: {
                    Text("Goal Reached")
                })
                    .disabled(!self.data.notificationsAllowed && self.data.notificationAccessAsked)
                Toggle(isOn: self.$data.showSignificantAmounts, label: {
                    Text("Significant Amounts")
                })
                    .disabled(!self.data.notificationsAllowed && self.data.notificationAccessAsked)
                Toggle(isOn: self.$data.showMilestoneAdded, label: {
                    Text("Milestones Added")
                })
                    .disabled(!self.data.notificationsAllowed && self.data.notificationAccessAsked)
            }
            if(!self.data.notificationsAllowed && self.data.notificationAccessAsked) {
                Section() {
                    Button(action: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            if(UIApplication.shared.canOpenURL(url)) {
                                UIApplication.shared.open(url, options: [:], completionHandler: {_ in})
                            }
                        }
                    }, label: {
                        Text("Notification access denied.")
                    })
                }
            }
        }
        .navigationBarTitle("Notifications")
        .toolbar(content: {
            ToolbarItem(placement: .primaryAction, content: {
                Button(action: self.onDismiss) {
                    Text("Done")
                        .bold()
                }
            })
        })
        .onAppear(perform: {
            self.data.refresh()
        })
        .onChange(of: scenePhase) { newPhase in
            if scenePhase == .background && newPhase != .background{
                self.data.refresh()
            }
        }
    }
}

struct NotificationSettings_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettings(onDismiss: {})
    }
}
