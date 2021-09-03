//
//  Color.swift
//  Color
//
//  Created by David on 03/09/2021.
//

import Foundation
import SwiftUI

extension Color {
    #if os(macOS)
    static let secondarySystemBackground = Color(NSColor.controlBackgroundColor)
    #else
    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
    #endif
    
    #if os(macOS)
    static let tertiarySystemBackground = Color(NSColor.underPageBackgroundColor)
    #else
    static let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)
    #endif
    
    #if os(macOS)
    static let quaternarySystemFill = Color(NSColor.windowBackgroundColor)
    #else
    static let quaternarySystemFill = Color(UIColor.quaternarySystemFill)
    #endif
    
    
    #if os(macOS)
    static let label = Color(NSColor.labelColor)
    #else
    static let label = Color(UIColor.label)
    #endif
}
