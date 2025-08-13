//
//  Players.swift
//  St Jude
//
//  Created by Pierre-Luc Robitaille on 2025-08-11.
//

import DeveloperToolsSupport

struct PlayerImage{
    var baseImage: ImageResource
    var lightImage: ImageResource
    var throwImage: ImageResource?
    var fightImage: ImageResource
    var streetImage: ImageResource
    var throwScale: Double?
    var baseScale: Double
    var figthScale: Double
    var bottomPadding: Double
    var isPaddingMirrored: Bool = false
    var horizontalPadding: Double = 15.0
    var isFightImageMirrored = false
}

enum Players: CaseIterable, Identifiable{
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
                                           throwScale: 0.13,
                                           baseScale: 0.10,
                                           figthScale: 0.25, // TODO: Adjust this
                                           bottomPadding: 22.5,
                                           isPaddingMirrored: true)
            
        case .myke : return PlayerImage(baseImage: .mykeSuit,
                                        lightImage: .mykeLights,
                                        throwImage: .mykeThrowSuit,
                                        fightImage: .mykeFighting,
                                        streetImage: .mykeStreet,
                                        throwScale: 0.24,
                                        baseScale: 0.10,
                                        figthScale: 0.26, // TODO: Adjust this
                                        bottomPadding: 6.8)
            
        case .casey : return PlayerImage(baseImage: .caseySuit,
                                         lightImage: .caseyLights,
                                         fightImage: .caseyFighting,
                                         streetImage: .caseyStreet,
                                         baseScale: 0.10,
                                         figthScale: 0.25,
                                         bottomPadding: -5.3,
                                         horizontalPadding: 40.0)
            
        case .kathy : return PlayerImage(baseImage: .kathySuit,
                                         lightImage: .kathyLights,
                                         fightImage: .kathyFighting,
                                         streetImage: .kathyStreet,
                                         baseScale: 0.10,
                                         figthScale: 0.20,
                                         bottomPadding: 26.8,
                                         isFightImageMirrored: true)
            
        case .jason : return PlayerImage(baseImage: .jasonSuit,
                                         lightImage: .jasonLights,
                                         fightImage: .jasonFighting,
                                         streetImage: .jasonStreet,
                                         baseScale: 0.10,
                                         figthScale: 0.20,
                                         bottomPadding: -0.75,
                                         isPaddingMirrored: true)
            
        case .brad : return PlayerImage(baseImage: .bradSuit,
                                        lightImage: .bradLights,
                                        fightImage: .bradFighting,
                                        streetImage: .bradStreet,
                                        baseScale: 0.10,
                                        figthScale: 0.25,
                                        bottomPadding: 1.5)
        }
    }
}
