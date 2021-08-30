//
//  UIApplication.swift
//  UIApplication
//
//  Created by Ben Cardy on 30/08/2021.
//

import UIKit

extension UIApplication {
    static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }
    static var buildNumber: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    }
    static var appName: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Unknown"
    }
    static var displayName: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? appName
    }
}
