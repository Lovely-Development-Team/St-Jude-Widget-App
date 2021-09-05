//
//  Notifications.swift
//  Notifications
//
//  Created by Justin Hamilton on 8/31/21.
//

import Foundation
import UserNotifications

func sendNotification(_ title: String, message: String?) {
    
    let content = UNMutableNotificationContent()
    content.title = title
    if let message = message {
        content.body = message
    }
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
    let id = UUID().uuidString
    
    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request, withCompletionHandler: {(error) in
        if let e = error {
            dataLogger.error("could not schedule notification: \(e.localizedDescription)")
        }
    })
}

class CustomNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

var customNotificationDelegate: CustomNotificationDelegate!

func initNotificationCenter() {
    customNotificationDelegate = CustomNotificationDelegate()
    UNUserNotificationCenter.current().delegate = customNotificationDelegate
}

func setNotificationPreference(newValue: Bool?, for key: String?) {
    UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {(settings) in
        switch(settings.authorizationStatus) {
        case .authorized:
            if let key = key, let newValue = newValue { UserDefaults.shared.set(newValue, forKey: key) }
            break
        case .denied:
            if let key = key, let _ = newValue { UserDefaults.shared.set(false, forKey: key) }
            break
        default:
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound], completionHandler: {(authorized, error) in
                if let e = error {
                    dataLogger.error("could not request notification authorization: \(e.localizedDescription)")
                    if let key = key, let _ = newValue { UserDefaults.shared.set(false, forKey: key) }
                    return
                }
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .init("NotificationAccessChangedNotification"), object: nil)
                }
                if let key = key,
                    let newValue = newValue {
                    setNotificationPreference(newValue: authorized ? newValue : false, for: key)
                }
            })
        }
    })
}
