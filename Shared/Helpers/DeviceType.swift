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
        
    public static func isSmallPhone() -> Bool {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return mapToIsSmallPhone(identifier: identifier)
    }
    
    private static func mapToIsSmallPhone(identifier: String) -> Bool {
        switch identifier {
        case "iPhone8,1", // iPhone 6s
            "iPhone9,1", // iPhone 7
            "iPhone10,1", "iPhone10,4", //iPhone 8
            "iPhone8,4", // iPhone SE
            "iPod9,1", // iPodTouch7
            "iPhone13,1": // iPhone SE2
            return true
        case "iPhone12,8": // iPhone 12 Mini
            return true
        case "i386", "x86_64", "arm64":
            guard let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] else {
                return false
            }
            return mapToIsSmallPhone(identifier: simulatorModelIdentifier)
        default:
            return false
        }
    }
}
