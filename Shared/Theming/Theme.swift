//
//  Theme.swift
//  St Jude (iOS)
//
//  Created by Justin Hamilton on 6/9/26.
//

import Foundation
import SwiftUI

enum Theme: Int, CaseIterable {
    case normal = 0
    case campaign2024 = 1
    case campaign2025 = 2
    
    var accentColor: Color {
        switch self {
        case .campaign2024:
            return .brandYellow
        default:
            return .brandRed
        }
    }
    
    var contentColorForAccent: Color {
        switch self {
        case .campaign2024:
            return .primary
        default:
            return .white
        }
    }
    
    static var defaultTheme: Theme {
        // Update this for the current campaign
        return .normal
    }
    
    static var current: Theme {
        return Theme(rawValue: UserDefaults.shared.selectedTheme) ?? Self.defaultTheme
    }
    
    static var isThemeApplied: Bool {
        return Self.current != .normal
    }
    
    var displayString: String {
        switch self {
        case .campaign2024:
            return "2024"
        case .campaign2025:
            return "2025"
        default:
            return "Default"
        }
    }
}
