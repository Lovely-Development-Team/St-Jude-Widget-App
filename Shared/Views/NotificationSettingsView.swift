//
//  NotificationSettings.swift
//  NotificationSettings
//
//  Created by Justin Hamilton on 8/31/21.
//

import SwiftUI
import UserNotifications
import Combine

struct NotificationSettingsView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var notificationSettings: NotificationSettings? = nil
    @State private var keyboardShowing: Bool = false
    
    @State private var notifyOnGoalReached: Bool = false
    @State private var notifyOnMilestonesReached: Bool = false
    @State private var notifyOnNewMilestone: Bool = false
    @State private var notifyOnNewReward: Bool = false
    
    @State private var notifyOnCustomAmount: Bool = false
    @State private var customAmountInput: String = "100,000"
    @State private var invalidCustomAmount: Bool = false
    
    @State private var notificationsAllowed: Bool = false
    @State private var notificationAccessAsked: Bool = false
    
    @State private var askNotificationAccessDisabled: Bool = false
    
    let id: UUID
    
    var body: some View {
        NavigationView {
            Form {
                if notificationSettings != nil {
                    Section {
                        Toggle("Milestone Reached", isOn: $notifyOnMilestonesReached)
                            .disabled(!notificationsAllowed && notificationAccessAsked)
                        Toggle("Goal Reached", isOn: $notifyOnGoalReached)
                            .disabled(!notificationsAllowed && notificationAccessAsked)
                        Toggle("Milestones Added", isOn: $notifyOnNewMilestone)
                            .disabled(!notificationsAllowed && notificationAccessAsked)
                        Toggle("Rewards Added", isOn: $notifyOnNewReward)
                            .disabled(!notificationsAllowed && notificationAccessAsked)
                    }
                    
                    Section(header: EmptyView().accessibility(hidden: true)) {
                        Toggle("Custom Amount", isOn: $notifyOnCustomAmount.animation())
                            .disabled(!notificationsAllowed && notificationAccessAsked)
                        if notifyOnCustomAmount {
                            HStack(spacing: 0) {
                                Text("$")
                                    .foregroundColor(invalidCustomAmount ? .red : .label)
                                TextField(" Enter Amount", text: $customAmountInput)
                                    .keyboardType(.decimalPad)
                                    .foregroundColor(invalidCustomAmount ? .red : .label)
                                if (keyboardShowing) {
                                    Button(action: {
#if os(macOS)
                                        NSApplication.shared.sendAction(#selector(NSResponder.resignFirstResponder), to: nil, from: nil)
#else
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
#endif
                                        let newNotificationSettings = NotificationSettings(id: id, notifyOnGoalReached: notifyOnGoalReached, notifyOnMilestonesReached: notifyOnMilestonesReached, notifyOnNewMilestone: notifyOnNewMilestone, notifyOnNewReward: notifyOnNewReward, customNotificationAmount: getNumberFromFormattedString(customAmountInput) as? Double)
                                        updateNotificationSettings(with: newNotificationSettings)
                                    }, label: {
                                        Text("Done")
                                            .bold()
                                    })
                                    .disabled(invalidCustomAmount)
                                    .animation(.easeInOut(duration: 0.25))
                                }
                            }
                        }
                    }
                    
                    if(!notificationsAllowed && notificationAccessAsked) {
                        Section() {
                            Button(action: {
                                if let url = systemSettingsNotificationsUrl() {
                                    openURL(url)
                                }
                            }, label: {
                                HStack {
                                    Text("Notification access denied")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                            })
                        }
                    }
                } else {
                    Text("Loading settings...")
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
//                if scenePhase != .active && newPhase != .background {
//                    self.data.refresh()
//                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification, object: nil), perform: { (notification) in
//                self.data.deformatText()
                deformatText()
                self.keyboardShowing = true
            })
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification), perform: { (notification) in
//                self.data.formatText()
                formatText()
                self.keyboardShowing = false
            })
            .onReceive(NotificationCenter.default.publisher(for: .init("NotificationAccessChangedNotification"), object: nil), perform: {(notification) in
//                self.data.refresh()
            })
            .onChange(of: notifyOnGoalReached) { newValue in
                askForNotificationsAccess {
                    let newNotificationSettings = NotificationSettings(id: id, notifyOnGoalReached: newValue, notifyOnMilestonesReached: notifyOnMilestonesReached, notifyOnNewMilestone: notifyOnNewMilestone, notifyOnNewReward: notifyOnNewReward)
                    updateNotificationSettings(with: newNotificationSettings)
                }
            }
            .onChange(of: notifyOnMilestonesReached) { newValue in
                askForNotificationsAccess {
                    let newNotificationSettings = NotificationSettings(id: id, notifyOnGoalReached: notifyOnGoalReached, notifyOnMilestonesReached: newValue, notifyOnNewMilestone: notifyOnNewMilestone, notifyOnNewReward: notifyOnNewReward)
                    updateNotificationSettings(with: newNotificationSettings)
                }
            }
            .onChange(of: notifyOnNewMilestone) { newValue in
                askForNotificationsAccess {
                    let newNotificationSettings = NotificationSettings(id: id, notifyOnGoalReached: notifyOnGoalReached, notifyOnMilestonesReached: notifyOnMilestonesReached, notifyOnNewMilestone: newValue, notifyOnNewReward: notifyOnNewReward)
                    updateNotificationSettings(with: newNotificationSettings)
                }
            }
            .onChange(of: notifyOnNewReward) { newValue in
                askForNotificationsAccess {
                    let newNotificationSettings = NotificationSettings(id: id, notifyOnGoalReached: notifyOnGoalReached, notifyOnMilestonesReached: notifyOnMilestonesReached, notifyOnNewMilestone: notifyOnNewMilestone, notifyOnNewReward: newValue)
                    updateNotificationSettings(with: newNotificationSettings)
                }
            }
            .onChange(of: customAmountInput) { newValue in
                if getNumberFromFormattedString(newValue) != nil {
                    invalidCustomAmount = false
                } else {
                    invalidCustomAmount = true
                }
            }
            .onAppear {
                checkNotificationSettingsStatus()
                Task {
                    do {
                        notificationSettings = try await AppDatabase.shared.fetchNotificationSettings(for: id)
                        if let notificationSettings = notificationSettings {
                            refreshUI(with: notificationSettings)
                        }
                    } catch {
                        dataLogger.error("Could not fetch Notification Settings: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func askForNotificationsAccess(onSuccess: @escaping () -> ()) {
        if !askNotificationAccessDisabled {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound]) { authorized, error in
                if let e = error {
                    dataLogger.error("could not request notification authorization: \(e.localizedDescription)")
                    notificationsAllowed = false
                }
                notificationAccessAsked = true
                notificationsAllowed = authorized
                if authorized {
                    onSuccess()
                }
            }
        }
    }
    
    func checkNotificationSettingsStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                print("Settings: Authorized")
                notificationsAllowed = true
                notificationAccessAsked = true
            case .denied:
                print("Settings: Denied")
                notificationsAllowed = false
                notificationAccessAsked = true
            default:
                print("Settings: ??")
                notificationsAllowed = false
                notificationAccessAsked = false
            }
        }
    }
    
    func updateNotificationSettings(with newNotificationSettings: NotificationSettings) {
        if let notificationSettings = notificationSettings {
            Task {
                do {
                    if try await AppDatabase.shared.updateNotificationSettings(newNotificationSettings, changesFrom: notificationSettings) {
                        self.notificationSettings = newNotificationSettings
                    }
                } catch {
                    dataLogger.warning("Could not update notificationSettings: \(error.localizedDescription)")
                    do {
                        try await AppDatabase.shared.saveNotificationSettings(newNotificationSettings)
                    } catch {
                        dataLogger.error("Could not save new notificationSettings: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func refreshUI(with notificationSettings: NotificationSettings) {
        askNotificationAccessDisabled = true
        notifyOnGoalReached = notificationSettings.notifyOnGoalReached
        notifyOnMilestonesReached = notificationSettings.notifyOnMilestonesReached
        notifyOnNewMilestone = notificationSettings.notifyOnNewMilestone
        notifyOnNewReward = notificationSettings.notifyOnNewReward
        if let customAmount = notificationSettings.customNotificationAmount {
            customAmountInput = getFormattedStringFromNumber(customAmount as NSNumber) ?? "0"
            notifyOnCustomAmount = true
        } else {
            notifyOnCustomAmount = false
            customAmountInput = ""
        }
        askNotificationAccessDisabled = false
    }
    
    func formatText() {
        guard let number = getNumberFromFormattedString(customAmountInput) else { return }
        guard let string = getFormattedStringFromNumber(number) else { return }
        customAmountInput = string
    }
    
    func deformatText() {
        guard let number = getNumberFromFormattedString(customAmountInput) else { return }
        customAmountInput = number.stringValue
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
    
}
