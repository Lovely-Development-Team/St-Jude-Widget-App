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
    var FightImage: ImageResource
    var StreetImage: ImageResource
    var ThrowScale: Double?
    var BaseScale: Double
    var FigthScale: Double
    var isPaddingMirrored: Bool = false
    var Padding: Double = 30.0
    var FightImageMirrored = false
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
    let player: players
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){ self.animate.toggle()}
        }){
            HStack{
                if (self.isMirrored && self.player.getPlayer().isPaddingMirrored) || (!self.isMirrored && !self.player.getPlayer().isPaddingMirrored) {
                    Spacer()
                }
                ZStack {
                    if !self.animate{
                        AdaptiveImage(colorScheme: self.colorScheme, light: self.player.getPlayer().BaseImage)
                            .imageAtScale(scale: .spriteScale * self.scale * self.player.getPlayer().BaseScale)
                            .padding( self.player.getPlayer().isPaddingMirrored ? .leading : .trailing, self.player.getPlayer().Padding)
                    }
                    else{
                        AdaptiveImage(colorScheme: self.colorScheme, light: self.player.getPlayer().ThrowImage ?? self.player.getPlayer().FightImage)
                            .imageAtScale(scale:  .spriteScale * self.scale * (self.player.getPlayer().ThrowScale ?? self.player.getPlayer().FigthScale))
                            .scaleEffect(x: self.player.getPlayer().FightImageMirrored ? -1 : 1, y: 1)
                            .padding(.vertical)
                    }
                }
                .padding(self.player.getPlayer().isPaddingMirrored ? .leading : .trailing, 5)
                .scaleEffect(x: isMirrored ? -1 : 1, y: 1)
                .animation(animate ? .none : animationType)
                
                if (!self.isMirrored && self.player.getPlayer().isPaddingMirrored) || (self.isMirrored && !self.player.getPlayer().isPaddingMirrored) {
                    Spacer()
                }
            }
        }
    }
}


#Preview {

    ScrollView{
        StandingToThrowingView(player: .brad, isMirrored: true)
        StandingToThrowingView(player: .myke, scale: 0.5, isMirrored: true)
        StandingToThrowingView(player: .jason, scale: 0.5, isMirrored: true)
        StandingToThrowingView(player: .stephen,scale: 0.6, isMirrored: true)
        StandingToThrowingView(player: .kathy, scale: 0.6, isMirrored: true)
        StandingToThrowingView(player: .casey, scale: 0.6, isMirrored: true)
    }
}
