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
    
    static let stephenYellow = Color.rgb(255, 187, 4)
    static let mykeBlue = Color.rgb(3, 84, 208)
    static let mykeRed = Color.rgb(158, 40, 53)
    
    static let skyBlue = Color.rgb(148, 222, 231)
    static let grassBorderGreen = Color.rgb(10, 93, 2)
    static let grassGreen = Color.rgb(72, 179, 5)
    static let groundBrown1 = Color.rgb(239, 185, 104)
    static let groundBrown2 = Color.rgb(211, 157, 76)
    
    static let slimePurple = Color.rgb(0x50, 0x14, 0x84)
    static let fireRed = Color.rgb(0xc7, 0x25, 0x2e)
    
    static let allCases: [WidgetAppearance] = [
        .stjude,
        .stjudetrueblack,
        .relay,
        .relaytrueblack,
        .yellow,
//        .blue,
//        .purple,
//        .green,
//        .red,
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
            return "Relay Gold"
//        case .blue:
//            return "Sky Blue"
//        case .purple:
//            return "Slime Purple"
//        case .ground:
//            return "Ground Brown"
//        case .red:
//            return "Fire Red"
//        case .green:
//            return "Grass Green"
        default:
            return "Unknown"
        }
    }
    
    var foregroundColor: Color {
        switch self {
            
        case .yellow:
            return .black
//        case .red:
//            return .white
//        case .blue:
//            return .black
//        case .green:
//            return .white
//        case .ground:
//            return .black
            
        default:
            return .white
        }
    }
    
    var fillColor: Color {
        switch self {
            
        case .yellow:
            return .black
//        case .red:
//            return .white
//        case .blue:
//            return .black
//        case .green:
//            return .white
//        case .ground:
//            return .black
//        case .purple:
//            return .white
            
            
            
        case .relay:
            return Self.relayYellow
        case .relaytrueblack:
            return Self.relayYellow
            
        default:
            return Self.stjudeRed
        }
    }
    
    var comboFillColor: Color {
        switch self {
        case .stjude, .stjudetrueblack:
            return Self.relayYellow
        default:
            return Self.stjudeRed
        }
    }
    
    var backgroundColors: [Color] {
        switch self {
            
        case .yellow:
            return [Self.stephenYellow, Self.stephenYellow.darker(by: 5)]
//        case .red:
//            return [Self.fireRed.darker(by: 10), Self.fireRed]
//        case .blue:
//            return [Self.skyBlue, Self.skyBlue.darker(by: 10)]
//        case .green:
//            return [Self.grassGreen, Self.grassGreen.darker(by: 10)]
//        case .ground:
//            return [Self.groundBrown2, Self.groundBrown2.darker(by: 10)]
//        case .purple:
//            return [Self.slimePurple.darker(by: 5), Self.slimePurple]
            
            
            
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
