//
//  Theme.swift
//  St Jude (iOS)
//
//  Created by Justin Hamilton on 6/9/26.
//

import Foundation
import SwiftUI

enum Theme: String {
    case normal = "normal"
    case campaign2024 = "2024"
    case campaign2025 = "2025"
    
    static var current: Theme {
        return .campaign2024
    }
    
    static var isThemeApplied: Bool {
        return Self.current != .normal
    }
}
