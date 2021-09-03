//
//  SystemSettings.swift
//  SystemSettings
//
//  Created by David on 03/09/2021.
//

import Foundation
import Cocoa

func systemSettingsNotificationsUrl() -> URL? {
    return URL(fileURLWithPath: "/System/Library/PreferencePanes/Notifications.prefPane", isDirectory: true)
}
