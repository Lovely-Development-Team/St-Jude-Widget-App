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
    case campaign2026 = 3
    
    var isPixel: Bool {
        return self == .campaign2024
        || self == .campaign2025
    }
    
    var accentColor: Color {
        switch self {
        case .campaign2024:
            return .brandYellow
        case .campaign2025:
            return WidgetAppearance.myke.fillColor
        default:
            return .brandRed
        }
    }
    
    var contentColorForAccent: Color {
        switch self {
        case .campaign2024:
            return .black
        case .campaign2025:
            return .black
        case .campaign2026:
            return .black
        default:
            return .white
        }
    }
    
    static var defaultTheme: Theme {
        // Update this for the current campaign
        return .campaign2026
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
        case .campaign2026:
            return "2026"
        default:
            return "Default"
        }
    }
    
    var imageScale: Double {
        switch self {
        case .campaign2026:
            return 0.1
        default:
            return Double.spriteScale
        }
    }
}
