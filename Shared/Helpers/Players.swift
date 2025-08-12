//
//  Players.swift
//  St Jude
//
//  Created by Pierre-Luc Robitaille on 2025-08-11.
//

struct PlayerImage{
    var BaseImage: ImageResource
    var LightImage: ImageResource
    var ThrowImage: ImageResource?
    var FightImage: ImageResource
    var StreetImage: ImageResource
    var ThrowScale: Double?
    var BaseScale: Double
    var FigthScale: Double
    var BottomPadding: Double
    var isPaddingMirrored: Bool = false
    var HorizontalPadding: Double = 15.0
    var FightImageMirrored = false
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
        case .stephen : return PlayerImage(BaseImage: .stephenSuit,
                                           LightImage: .stephenLights,
                                           ThrowImage: .stephenDodgeSuit,
                                           FightImage: .stephenFighting,
                                           StreetImage: .stephenStreet,
                                           ThrowScale: 0.13,
                                           BaseScale: 0.10,
                                           FigthScale: 0.25, // TODO: Adjust this
                                           BottomPadding: 22.5,
                                           isPaddingMirrored: true)
            
        case .myke : return PlayerImage(BaseImage: .mykeSuit,
                                        LightImage: .mykeLights,
                                        ThrowImage: .mykeThrowSuit,
                                        FightImage: .mykeFighting,
                                        StreetImage: .mykeStreet,
                                        ThrowScale: 0.24,
                                        BaseScale: 0.10,
                                        FigthScale: 0.26, // TODO: Adjust this
                                        BottomPadding: 6.8)
            
        case .casey : return PlayerImage(BaseImage: .caseySuit,
                                         LightImage: .caseyLights,
                                         FightImage: .caseyFighting,
                                         StreetImage: .caseyStreet,
                                         BaseScale: 0.10,
                                         FigthScale: 0.25,
                                         BottomPadding: -5.3,
                                         HorizontalPadding: 40.0)
            
        case .kathy : return PlayerImage(BaseImage: .kathySuit,
                                         LightImage: .kathyLights,
                                         FightImage: .kathyFighting,
                                         StreetImage: .kathyStreet,
                                         BaseScale: 0.10,
                                         FigthScale: 0.20,
                                         BottomPadding: 26.8,
                                         FightImageMirrored: true)
            
        case .jason : return PlayerImage(BaseImage: .jasonSuit,
                                         LightImage: .jasonLights,
                                         FightImage: .jasonFighting,
                                         StreetImage: .jasonStreet,
                                         BaseScale: 0.10,
                                         FigthScale: 0.20,
                                         BottomPadding: -0.75,
                                         isPaddingMirrored: true)
            
        case .brad : return PlayerImage(BaseImage: .bradSuit,
                                        LightImage: .bradLights,
                                        FightImage: .bradFighting,
                                        StreetImage: .bradStreet,
                                        BaseScale: 0.10,
                                        FigthScale: 0.25,
                                        BottomPadding: 1.5)
        }
    }
}
