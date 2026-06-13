//
//  ThemeManager.swift
//  St Jude (iOS)
//
//  Created by Justin Hamilton on 6/9/26.
//

import Foundation

struct ThemeManager {
    static var currentTheme: Theme {
        return .normal
    }
    
    static var hasThemeApplied: Bool {
        return Self.currentTheme != .normal
    }
}
