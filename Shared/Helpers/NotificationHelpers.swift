//
//  NotificationHelpers.swift
//  St Jude
//
//  Created by Justin Hamilton on 9/12/24.
//

import Foundation

extension NotificationCenter {
    static let globalNotificationTitleKey = "GlobalNotificationTitle"
    static let globalNotificationMessageKey = "GlobalNotificationMessage"
    
    static func showGlobalAlert(title: String, message: String) {
        let data: [AnyHashable: Any] = [
            NotificationCenter.globalNotificationTitleKey: title,
            NotificationCenter.globalNotificationMessageKey: message
        ]
        
        NotificationCenter.default.post(name: .displayGlobalNotification, object: nil, userInfo: data)
    }
}

extension Notification.Name {
    // Global popup alert
    static let displayGlobalNotification = NSNotification.Name("DisplayGlobalNotification")
}
