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
    
    // Will act as default
    private var lightAccentColor: Color {
        switch self {
        case .campaign2024:
            return .brandYellow
        case .campaign2025:
            return WidgetAppearance.stjude.fillColor
        case .campaign2026:
            return .accentColor2026
        default:
            return .brandRed
        }
    }
    
    // Specify nil if this theme's accent color doesn't adjust for light/dark mode
    private var darkAccentColor: Color? {
        switch self {
        case .campaign2026:
            return .brandRed
        default:
            return nil
        }
    }
    
    var accentColor: Color {
        guard let darkColor = self.darkAccentColor else {
            return self.lightAccentColor
        }
        
        return Color(uiColor: UIColor(dynamicProvider: { traits in
            switch traits.userInterfaceStyle {
            case .dark:
                return UIColor(darkColor)
            default:
                return UIColor(self.lightAccentColor)
            }
        }))
    }
    
    // Used for the combo fill on the campaign progress bars and H2H opponent
    var alternateAccentColor: Color {
        switch self {
        case .campaign2026:
            return .brandYellow.darker(by: 5)
        default:
            return .brandYellow
        }
    }
    
    var contentColorForAccent: Color {
        switch self {
        case .campaign2024:
            return .black
        case .campaign2025:
            return .black
        case .campaign2026:
            return .white
        default:
            return .white
        }
    }
    
    var contentColorForAlternateAccent: Color {
        switch self {
        default:
            return .black
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
            return 0.5
        default:
            return Double.spriteScale
        }
    }
    
    var forcedColorScheme: ColorScheme? {
        switch self {
        case .campaign2025:
            return .dark
//        case .campaign2026:
//            return .light
        default:
            return nil
        }
    }
    
    var didJustinContributeArt: Bool {
        switch self {
        case .campaign2024, .campaign2025, .campaign2026:
            return true
        default:
            return false
        }
    }
    
    var hasCustomRandomCampaignPicker: Bool {
        return self == .campaign2024 || self == .campaign2026
    }
}
