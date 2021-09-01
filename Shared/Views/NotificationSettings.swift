//
//  NotificationSettings.swift
//  NotificationSettings
//
//  Created by Justin Hamilton on 8/31/21.
//

import SwiftUI
import UserNotifications

class NotificationSettingsData: ObservableObject {

    private var refreshing = false
    
    @Published var showMilestones: Bool {
        didSet {
            if(!refreshing) {
                UserDefaults.shared.showMilestoneNotification = self.showMilestones
            }
        }
    }
    
    @Published var showGoal: Bool {
        didSet {
            if(!refreshing) {
                UserDefaults.shared.showGoalNotification = self.showGoal
            }
        }
    }
    
    @Published var showSignificantAmounts: Bool {
        didSet {
            if(!refreshing) {
                UserDefaults.shared.showSignificantAmountNotification = self.showSignificantAmounts
            }
        }
    }
    
    @Published var showMilestoneAdded: Bool {
        didSet {
            if(!refreshing) {
                UserDefaults.shared.showMilestoneAddedNotification = self.showMilestoneAdded
            }
        }
    }
    
    @Published var notificationsAllowed: Bool = false
    
    init() {
        self.refreshing = true
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
            self.refreshing = false
        })
    }
}

struct NotificationSettings: View {
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var data = NotificationSettingsData()
        
    var body: some View {
        NavigationView {
            Form {
                Section(header: EmptyView().accessibility(hidden: true)) {
                    Toggle(isOn: self.$data.showMilestones, label: {
                        Text("Milestones")
                    })
                        .disabled(!self.data.notificationsAllowed)
                    Toggle(isOn: self.$data.showGoal, label: {
                        Text("Goal Reached")
                    })
                        .disabled(!self.data.notificationsAllowed)
                    Toggle(isOn: self.$data.showSignificantAmounts, label: {
                        Text("Significant Amounts")
                    })
                        .disabled(!self.data.notificationsAllowed)
                    Toggle(isOn: self.$data.showMilestoneAdded, label: {
                        Text("Milestones Added")
                    })
                        .disabled(!self.data.notificationsAllowed)
                }
                    if(!self.data.notificationsAllowed) {
                        Section(header: EmptyView().accessibility(hidden: true)) {
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
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                })
            })
        }
    }
}

struct NotificationSettings_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettings()
    }
}
