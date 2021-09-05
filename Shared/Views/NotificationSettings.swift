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
    
    @State private var keyboardShowing: Bool = false
    
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
                        HStack(spacing: 0) {
                            Text("$")
                                .foregroundColor((self.data.rejectedInputShowing) ? .red : .label)
                            TextField(" Enter Amount", text: self.$data.customAmountInput)
                                .keyboardType(.decimalPad)
                                .foregroundColor((self.data.rejectedInputShowing) ? .red : .label)
                            if(self.keyboardShowing) {
                                Button(action: {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }, label: {
                                    Text("Done")
                                        .bold()
                                })
                                    .disabled(self.data.rejectedInputShowing)
                                    .animation(.easeInOut(duration: 0.25))
                            }
                        }
                    }
                }
                
                //uncomment below to test custom amounts
//                Button(action: {
//                    UserDefaults.shared.removeObject(forKey: UserDefaults.customNotificationAmountKey)
//                    UserDefaults.shared.enableCustomAmountNotification = false
//                    self.data.customAmountInput = ""
//                    self.data.refresh()
//                }, label: {
//                    Text("Reset Custom Amount Prefs")
//                        .foregroundColor(.red)
//                })
                
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
                        .disabled(self.keyboardShowing)
                })
            })
            .onChange(of: scenePhase) { newPhase in
                if scenePhase != .active && newPhase != .background {
                    self.data.refresh()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification, object: nil), perform: { (notification) in
                self.data.deformatText()
                self.keyboardShowing = true
            })
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification), perform: { (notification) in
                self.data.formatText()
                self.keyboardShowing = false
            })
            .onReceive(NotificationCenter.default.publisher(for: .init("NotificationAccessChangedNotification"), object: nil), perform: {(notification) in
                self.data.refresh()
            })
        }
    }
}

struct NotificationSettings_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettings()
    }
}
