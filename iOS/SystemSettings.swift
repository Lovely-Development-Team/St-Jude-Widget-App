//
//  SystemSettings.swift
//  SystemSettings
//
//  Created by David on 03/09/2021.
//

import Foundation
import UIKit

func systemSettingsNotificationsUrl() -> URL? {
    guard let url = URL(string: UIApplication.openSettingsURLString) else {
        return nil
    }
    
    guard UIApplication.shared.canOpenURL(url) else {
        return nil
    }
    return url
}
