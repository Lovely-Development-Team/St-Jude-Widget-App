//
//  WidgetAppearance.swift
//  St Jude
//
//  Created by Ben Cardy on 30/08/2022.
//

import Foundation
import SwiftUI

extension WidgetAppearance {
    
    static let relayBlueDark = Color(.sRGB, red: 43 / 255, green: 54 / 255, blue: 61 / 255, opacity: 1)
    static let relayBlueLight = Color(.sRGB, red: 51 / 255, green: 63 / 255, blue: 72 / 255, opacity: 1)
    static let relayYellow = Color(.sRGB, red: 254 / 255, green: 206 / 255, blue: 52 / 255, opacity: 1)
    
    static let stjudeBlueDark = Color(red: 12 / 255, green: 25 / 255, blue: 56 / 255)
    static let stjudeBlueLight = Color(red: 13 / 255, green: 39 / 255, blue: 83 / 255)
    static let stjudeRed = Color(red: 195 / 255, green: 18 / 255, blue: 53 / 255)
    
    var foregroundColor: Color {
        switch self {
        case .relayinverted:
            return Self.relayBlueDark
        default:
            return .white
        }
    }
    
    var fillColor: Color {
        switch self {
        case .relay:
            return Self.relayYellow
        case .relayinverted:
            return Self.relayBlueLight
        case .stjudeinverted:
            return Self.stjudeBlueLight
        default:
            return Self.stjudeRed
        }
    }
    
    var backgroundColors: [Color] {
        switch self {
        case .relay:
            return [
                Self.relayBlueDark,
                Self.relayBlueLight
            ]
        case .relayinverted:
            return [
                Self.relayYellow
            ]
        case .stjudeinverted:
            return [
                Self.stjudeRed
            ]
        default:
            return [
                Self.stjudeBlueDark,
                Self.stjudeBlueLight
            ]
        }
    }
    
}
