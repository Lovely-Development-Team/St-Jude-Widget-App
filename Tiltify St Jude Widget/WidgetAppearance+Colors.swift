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
    
    // 2024
    
    static let stephenYellow = Color(red: 255 / 255, green: 186 / 255, blue: 4 / 255)
    static let mykeBlue = Color(red: 3 / 255, green: 84 / 255, blue: 208 / 255)
    
    static let allCases: [WidgetAppearance] = [
        .stjude,
        .stjudetrueblack,
        .relay,
        .relaytrueblack,
        .yellow,
        .blue,
        .purple,
        .green,
        .red,
    ]
    
    var name: String {
        switch self {
        case .stjude:
            return "St Jude"
        case .stjudetrueblack:
            return "St Jude (True Black)"
        case .relay:
            return "Relay"
        case .relaytrueblack:
            return "Relay (True Black)"
        case .yellow:
            return "Yellow"
        case .blue:
            return "Blue"
        case .purple:
            return "Purple"
        case .red:
            return "Red"
        default:
            return "Unknown"
        }
    }
    
    var foregroundColor: Color {
        switch self {
            
        case .yellow:
            return .black
        case .red:
            return .white
        case .blue:
            return .white
        case .green:
            return .white
        case .purple:
            return .white
            
        default:
            return .white
        }
    }
    
    var fillColor: Color {
        switch self {
            
        case .yellow:
            return .black
        case .red:
            return .white
        case .blue:
            return .white
        case .green:
            return .white
        case .purple:
            return .white
            
            
            
        case .relay:
            return Self.relayYellow
        case .relaytrueblack:
            return Self.relayYellow
            
        default:
            return Self.stjudeRed
        }
    }
    
    var backgroundColors: [Color] {
        switch self {
            
        case .yellow:
            return [Self.stephenYellow, Self.stephenYellow.darker(by: 5)]
        case .red:
            return [.brandRed, .brandRed.darker(by: 5)]
        case .blue:
            return [Self.mykeBlue, Self.mykeBlue.darker(by: 5)]
        case .green:
            return [.brandGreen, .brandGreen.darker(by: 5)]
        case .purple:
            return [.brandPurple, .brandPurple.darker(by: 5)]
            
            
            
        case .relaytrueblack:
            return [Color.black]
        case .stjudetrueblack:
            return [Color.black]
        case .relay:
            return [
                Self.relayBlueDark,
                Self.relayBlueLight
            ]
        default:
            return [
                Self.stjudeBlueDark,
                Self.stjudeBlueLight
            ]
        }
    }
    
}
