//
//  NotificationSettings.swift
//  NotificationSettings
//
//  Created by Justin Hamilton on 8/31/21.
//

import SwiftUI
import UserNotifications
import Combine

struct NotificationSettings: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var data = NotificationSettingsController()
    
    var body: some View {
        NavigationView {    
            Form {
                Section(header: EmptyView().accessibility(hidden: true), footer: Text("Significant amount notifications fire every $50k or when the goal is doubled, tripled, etc.")) {
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
                
                Section(header: EmptyView().accessibility(hidden: true)) {
                    Toggle(isOn: self.$data.enableCustomAmountNotification, label: {
                        Text("Custom Amount")
                    })
                        .disabled(!self.data.notificationsAllowed && self.data.notificationAccessAsked)
                    if(self.data.enableCustomAmountNotification) {
                        TextField("Enter Amount", text: self.$data.customAmountInput)
                            .foregroundColor((self.data.rejectedInputShowing) ? .red : Color(UIColor.label))
                    }
                }
                
                if(!self.data.notificationsAllowed && self.data.notificationAccessAsked) {
                    Section() {
                        Button(action: {
                            if let url = systemSettingsNotificationsUrl() {
                                openURL(url)
                            }
                        }, label: {
                            Text("Notification access denied.")
                        })
                    }
                }
            }
            .navigationTitle("Notifications")
            .toolbar(content: {
                ToolbarItem(placement: .primaryAction, content: {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Done")
                            .bold()
                    })
                })
            })
            .onChange(of: scenePhase) { newPhase in
                if scenePhase != .active && newPhase != .background {
                    self.data.refresh()
                }
            }
        }
    }
}

struct NotificationSettings_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettings()
    }
}
