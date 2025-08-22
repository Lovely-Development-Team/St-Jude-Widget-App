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
}

enum Player: Int, CaseIterable, Identifiable {
    var id: Self { self }
    
    case stephen
    case myke
    case casey
    case kathy
    case jason
    case brad
    
    func getPlayer() -> PlayerImage {
        switch self {
        case .stephen : return PlayerImage(baseImage: .stephenSuit,
                                           lightImage: .stephenLights,
                                           throwImage: .stephenDodgeSuit,
                                           fightImage: .stephenFighting,
                                           streetImage: .stephenStreet,
                                           headImage: .stephenHead,
                                           name: "Stephen",
                                           color: WidgetAppearance.stephenLights,
                                           figthScale: 1.0,
                                           bottomPadding: 12.5,
                                           isPaddingMirrored: true)
            
        case .myke : return PlayerImage(baseImage: .mykeSuit,
                                        lightImage: .mykeLights,
                                        throwImage: .mykeThrowSuit,
                                        fightImage: .mykeFighting,
                                        streetImage: .mykeStreet,
                                        headImage: .mykeHead,
                                        name: "Myke",
                                        color: WidgetAppearance.mykeLights,
                                        figthScale: 1,
                                        bottomPadding: 7.5)
            
        case .casey : return PlayerImage(baseImage: .caseySuit,
                                         lightImage: .caseyLights,
                                         fightImage: .caseyFighting,
                                         streetImage: .caseyStreet,
                                         headImage: .caseyHead,
                                         name: "Casey",
                                         color: WidgetAppearance.caseyLights,
                                         bottomPadding: 0.0,
                                         horizontalPadding: 40.0)
            
        case .kathy : return PlayerImage(baseImage: .kathySuit,
                                         lightImage: .kathyLights,
                                         fightImage: .kathyFighting,
                                         streetImage: .kathyStreet,
                                         headImage: .kathyHead,
                                         name: "Kathy",
                                         color: WidgetAppearance.kathyLights,
                                         bottomPadding: 22.5,
                                         isFightImageMirrored: true)
             
        case .jason : return PlayerImage(baseImage: .jasonSuit,
                                         lightImage: .jasonLights,
                                         fightImage: .jasonFighting,
                                         streetImage: .jasonStreet,
                                         headImage: .jasonHead,
                                         name: "Jason",
                                         color: WidgetAppearance.jasonLights,
                                         bottomPadding: 2.5,
                                         isPaddingMirrored: true)
            
        case .brad : return PlayerImage(baseImage: .bradSuit,
                                        lightImage: .bradLights,
                                        fightImage: .bradFighting,
                                        streetImage: .bradStreet,
                                        headImage: .bradHead,
                                        name: "Brad",
                                        color: WidgetAppearance.bradLights,
                                        bottomPadding: 7.5)
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
