//
//  Players.swift
//  St Jude
//
//  Created by Pierre-Luc Robitaille on 2025-08-11.
//

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
        case .stephen : return PlayerImage(BaseImage: .stephenSuit,
                                           LightImage: .stephenLights,
                                           ThrowImage: .stephenDodgeSuit,
                                           FightImage: .stephenFighting,
                                           StreetImage: .stephenStreet,
                                           ThrowScale: 0.125,
                                           BaseScale: 0.10,
                                           FigthScale: 0.25, // TODO: Adjust this
                                           isPaddingMirrored: true,
                                           Padding: 15.0)
            
        case .myke : return PlayerImage(BaseImage: .mykeSuit,
                                        LightImage: .mykeLights,
                                        ThrowImage: .mykeThrowSuit,
                                        FightImage: .mykeFighting,
                                        StreetImage: .mykeStreet,
                                        ThrowScale: 0.25,
                                        BaseScale: 0.10,
                                        FigthScale: 0.26,
                                        Padding: 15.0) // TODO: Adjust this
            
        case .casey : return PlayerImage(BaseImage: .caseySuit,
                                         LightImage: .caseyLights,
                                         FightImage: .caseyFighting,
                                         StreetImage: .caseyStreet,
                                         BaseScale: 0.10,
                                         FigthScale: 0.25,
                                         Padding: 40.0)
            
        case .kathy : return PlayerImage(BaseImage: .kathySuit,
                                         LightImage: .kathyLights,
                                         FightImage: .kathyFighting,
                                         StreetImage: .kathyStreet,
                                         BaseScale: 0.10,
                                         FigthScale: 0.20,
                                         FightImageMirrored: true)
            
        case .jason : return PlayerImage(BaseImage: .jasonSuit,
                                         LightImage: .jasonLights,
                                         FightImage: .jasonFighting,
                                         StreetImage: .jasonStreet,
                                         BaseScale: 0.10,
                                         FigthScale: 0.20,
                                         isPaddingMirrored: true,
                                         Padding: 24.0)
            
        case .brad : return PlayerImage(BaseImage: .bradSuit,
                                        LightImage: .bradLights,
                                        FightImage: .bradFighting,
                                        StreetImage: .bradStreet,
                                        BaseScale: 0.10,
                                        FigthScale: 0.25)
        }
    }
}
