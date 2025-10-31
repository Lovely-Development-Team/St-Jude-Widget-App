//
//  Players.swift
//  St Jude
//
//  Created by Pierre-Luc Robitaille on 2025-08-11.
//

import DeveloperToolsSupport
import SwiftUI

struct PlayerImage{
    var baseImage: ImageResource
    var lightImage: ImageResource
    var throwImage: ImageResource?
    var fightImage: ImageResource
    var streetImage: ImageResource
    var headImage: ImageResource
    var name: String
    var color: Color
    var throwScale: Double?
    var baseScale: Double = 1.0
    var figthScale: Double = 1.0
    var bottomPadding: Double
    var isPaddingMirrored: Bool = false
    var horizontalPadding: Double = 15.0
    var isFightImageMirrored = false
    var facingLeft: Bool = false
}

enum Player: Int, CaseIterable, Identifiable {
    var id: Self { self }
    
    case stephen
    case myke
    case casey
    case kathy
    case jason
    case brad
    
    var opponent: Player {
        switch self {
        case .stephen: return .myke
        case .myke: return .stephen
        case .kathy: return .jason
        case .jason: return .kathy
        case .brad: return .casey
        case .casey: return .brad
        }
    }
    
    func getPlayer() -> PlayerImage {
        switch self {
        case .stephen : return PlayerImage(baseImage: .stephenSuit2025,
                                           lightImage: .stephenLights2025,
                                           throwImage: .stephenDodgeSuit2025,
                                           fightImage: .stephenFighting2025,
                                           streetImage: .stephenStreet2025,
                                           headImage: .stephenHead2025,
                                           name: "Stephen",
                                           color: WidgetAppearance.stephenLights,
                                           figthScale: 1.0,
                                           bottomPadding: 12.5,
                                           isPaddingMirrored: true)
            
        case .myke : return PlayerImage(baseImage: .mykeSuit2025,
                                        lightImage: .mykeLights2025,
                                        throwImage: .mykeThrowSuit2025,
                                        fightImage: .mykeFighting2025,
                                        streetImage: .mykeStreet2025,
                                        headImage: .mykeHead2025,
                                        name: "Myke",
                                        color: WidgetAppearance.mykeLights,
                                        figthScale: 1,
                                        bottomPadding: 7.5,
                                        facingLeft: true)
            
        case .casey : return PlayerImage(baseImage: .caseySuit2025,
                                         lightImage: .caseyLights2025,
                                         fightImage: .caseyFighting2025,
                                         streetImage: .caseyStreet2025,
                                         headImage: .caseyHead2025,
                                         name: "Casey",
                                         color: WidgetAppearance.caseyLights,
                                         bottomPadding: 0.0,
                                         horizontalPadding: 40.0,
                                         facingLeft: true)
            
        case .kathy : return PlayerImage(baseImage: .kathySuit2025,
                                         lightImage: .kathyLights2025,
                                         fightImage: .kathyFighting2025,
                                         streetImage: .kathyStreet2025,
                                         headImage: .kathyHead2025,
                                         name: "Kathy",
                                         color: WidgetAppearance.kathyLights,
                                         bottomPadding: 22.5,
                                         isFightImageMirrored: true,
                                         facingLeft: true)
             
        case .jason : return PlayerImage(baseImage: .jasonSuit2025,
                                         lightImage: .jasonLights2025,
                                         fightImage: .jasonFighting2025,
                                         streetImage: .jasonStreet2025,
                                         headImage: .jasonHead2025,
                                         name: "Jason",
                                         color: WidgetAppearance.jasonLights,
                                         bottomPadding: 2.5,
                                         isPaddingMirrored: true)
            
        case .brad : return PlayerImage(baseImage: .bradSuit2025,
                                        lightImage: .bradLights2025,
                                        fightImage: .bradFighting2025,
                                        streetImage: .bradStreet2025,
                                        headImage: .bradHead2025,
                                        name: "Brad",
                                        color: WidgetAppearance.bradLights,
                                        bottomPadding: 7.5,
                                        facingLeft: true)
        }
    }
    
    static var displayOrder: [Player] {
        return [
            .myke,
            .stephen,
            .casey,
            .brad,
            .jason,
            .kathy
        ]
    }
    
    static var randomInitial: Player {
        return [Player.myke, Player.stephen].randomElement()!
    }
}
