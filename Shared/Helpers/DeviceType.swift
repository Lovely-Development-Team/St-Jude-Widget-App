//
//  DeviceType.swift
//  Medication Tracker
//
//  Created by David Stephens on 10/06/2021.
//

import SwiftUI

public enum DeviceType {
    @inlinable
    public static func isPhone() -> Bool {
        #if os(iOS)
        return UIDevice().userInterfaceIdiom == .phone
        #else
        return false
        #endif
    }
    
    @inlinable
    public static func isPad() -> Bool {
        #if os(iOS)
        return UIDevice().userInterfaceIdiom == .pad
        #else
        return false
        #endif
    }
    
    @inlinable
    public static func isMac() -> Bool {
        #if !os(macOS)
        return false
        #else
        return true
        #endif
    }
    
    @inlinable
    public static func isWatch() -> Bool {
        #if !os(watchOS)
        return false
        #else
        return true
        #endif
    }
    
    @inlinable
    public static func isInWidget() -> Bool {
        guard let extesion = Bundle.main.infoDictionary?["NSExtension"] as? [String: String] else { return false }
        guard let widget = extesion["NSExtensionPointIdentifier"] else { return false }
        return widget == "com.apple.widgetkit-extension"
    }
    
    @inlinable
    public static func isPreview() -> Bool {
        #if DEBUG
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        #else
        // Release builds should never be running in a preview
        return false
        #endif
    }
}
