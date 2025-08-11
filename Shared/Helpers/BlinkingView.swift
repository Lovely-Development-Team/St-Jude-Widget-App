//
//  BlinkingView.swift
//  St Jude
//
//  Created by Pierre-Luc Robitaille on 2025-08-11.
//

import SwiftUI

struct BlinkingView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var baseImage:ImageResource
    @State var blinkImage:ImageResource
    let bounceHaptics = UIImpactFeedbackGenerator(style: .light)
    @State var animate:Bool = false
    @State private var animationType: Animation? = .none

    var body: some View {
        Button(action: {
            withAnimation {
#if !os(macOS)
                bounceHaptics.impactOccurred()
#endif
                self.animate.toggle()
                self.animationType = .default
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                self.animate.toggle()
            }
        }) {
            ZStack(alignment: .top){
                AdaptiveImage(colorScheme: self.colorScheme, light: self.baseImage)
                    .imageAtScale(scale: .spriteScale * 0.5)
                    .padding(11)
                if(animate){
                    AdaptiveImage(colorScheme: self.colorScheme, light: self.blinkImage)
                        .imageAtScale(scale: .spriteScale * 0.75)
                }
            }
            .animation(animate ? .linear(duration: 1).repeatForever(autoreverses: true) : animationType)
            
        }
    }
}

struct PlayerImage{
    var BaseImage: ImageResource
    var LightImage: ImageResource
    var ThrowImage: ImageResource?
    var FigthImage: ImageResource
    var StreetImage: ImageResource
    var ThrowScale: Double?
    var BaseScale: Double
    var FigthScale: Double
    var isPaddingMirrored: Bool = false
    var Padding: Double = 30.0
    var figthImageMirrored = false
}



struct BlinkingStandingView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var baseImage:ImageResource
    @State var lightImage:ImageResource
    let bounceHaptics = UIImpactFeedbackGenerator(style: .light)
    @State var animate:Bool = false
    @State private var animationType: Animation? = .none
    @State var scale: Double = 1
    @State var isMirrored: Bool = false
    
    var body: some View{
        Button(action: {
            withAnimation {
#if !os(macOS)
                bounceHaptics.impactOccurred()
#endif
                self.animate.toggle()
                self.animationType = .default
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                self.animate.toggle()
            }
        }) {
            ZStack(alignment: .top){
                AdaptiveImage(colorScheme: self.colorScheme, light: self.baseImage)
                    .imageAtScale(scale: self.scale * .spriteScale * 0.5)
                if(animate){
                    AdaptiveImage(colorScheme: self.colorScheme, light: self.lightImage)
                        .imageAtScale(scale: self.scale * .spriteScale * 0.5)
                            .brightness(0.15)
                }
            }
            .scaleEffect(x: isMirrored ? -1 : 1, y: 1)
            .animation(animate ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : animationType)
            
        }
    }
}


struct StandingToThrowingView: View{
    let player: PlayerImage
    @State var scale: Double = 1.0
    @State var isMirrored: Bool = false
    
    let bounceHaptics = UIImpactFeedbackGenerator(style: .light)
    @State private var animate = false
    @State private var animationType: Animation? = .none
    @Environment(\.colorScheme) var colorScheme
    var body: some View{

        Button(action: {
#if !os(macOS)
                bounceHaptics.impactOccurred()
#endif
            self.animate.toggle()
        }){
            HStack{
                if self.player.isPaddingMirrored {
                    Spacer()
                }
                
                ZStack {
                    if !self.animate{
                        AdaptiveImage(colorScheme: self.colorScheme, light: self.player.BaseImage)
                            .imageAtScale(scale: .spriteScale * self.scale * self.player.BaseScale)
                            .padding( self.player.isPaddingMirrored ? .leading : .trailing, self.player.Padding)
                    }
                    else{
                        AdaptiveImage(colorScheme: self.colorScheme, light: self.player.ThrowImage ?? self.player.FigthImage)
                            .imageAtScale(scale:  .spriteScale * self.scale * (self.player.ThrowScale ?? self.player.FigthScale))
                            .scaleEffect(x: self.player.figthImageMirrored ? -1 : 1, y: 1)
                            .padding(.vertical)
                    }
                }
                .padding(self.player.isPaddingMirrored ? .leading : .trailing)
                .scaleEffect(x: isMirrored ? -1 : 1, y: 1)
                .animation(animate ? .none : animationType)
                
                if !self.player.isPaddingMirrored {
                    Spacer()
                }
            }
        }
    }
}


#Preview {
    let stephen = PlayerImage(BaseImage: .stephenSuit,
                              LightImage: .stephenLights,
                              ThrowImage: .stephenDodgeSuit,
                              FigthImage: .stephenFighting,
                              StreetImage: .stephenStreet,
                              ThrowScale: 0.25,
                              BaseScale: 0.20,
                              FigthScale: 0.25,
                              isPaddingMirrored: true)
    let myke = PlayerImage(BaseImage: .mykeSuit,
                           LightImage: .mykeLights,
                           ThrowImage: .mykeThrowSuit,
                           FigthImage: .mykeFighting,
                           StreetImage: .mykeStreet,
                           ThrowScale: 0.50,
                           BaseScale: 0.20,
                           FigthScale: 0.26,)
    let casey = PlayerImage(BaseImage: .caseySuit,
                            LightImage: .caseyLights,
                            FigthImage: .caseyFighting,
                            StreetImage: .caseyStreet,
                            BaseScale: 0.20,
                            FigthScale: 0.50,
                            Padding: 80.0)
    let kathy = PlayerImage(BaseImage: .kathySuit,
                            LightImage: .kathyLights,
                            FigthImage: .kathyFighting,
                            StreetImage: .kathyStreet,
                            BaseScale: 0.20,
                            FigthScale: 0.40,
                            figthImageMirrored: true)
    let jason = PlayerImage(BaseImage: .jasonSuit,
                            LightImage: .jasonLights,
                            FigthImage: .jasonFighting,
                            StreetImage: .jasonStreet,
                            BaseScale: 0.25,
                            FigthScale: 0.50,
                            isPaddingMirrored: true,
                            Padding: 75)
    let brad = PlayerImage(BaseImage: .bradSuit,
                           LightImage: .bradLights,
                           FigthImage: .bradFighting,
                           StreetImage: .bradStreet,
                           BaseScale: 0.10,
                           FigthScale: 0.25)
    StandingToThrowingView(player: brad, scale: 1, isMirrored: true)
}
