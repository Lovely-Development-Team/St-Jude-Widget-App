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

struct BlinkingStandingView: View {
    @Environment(\.colorScheme) var colorScheme
    let player: Player
    let bounceHaptics = UIImpactFeedbackGenerator(style: .light)
    @State var animate:Bool = false
    @State private var animationType: Animation? = .none
    @State var scale: Double = 1
    @State var isMirrored: Bool = false
    var onTap: (() -> Void)?

    var body: some View{
        let playerImage = player.getPlayer()
        HStack{
            if(!self.isMirrored){
                Spacer()
            }
            Button(action: {
                withAnimation {
#if !os(macOS)
                    bounceHaptics.impactOccurred()
#endif
                    self.onTap?()
                    animate.toggle()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    animate.toggle()
                }
            }) {
                ZStack(alignment: .top){
                    AdaptiveImage(colorScheme: self.colorScheme, light: playerImage.baseImage)
                        .imageAtScale(scale: self.scale * .spriteScale)
                    if(animate){
                        AdaptiveImage(colorScheme: self.colorScheme, light: playerImage.lightImage)
                            .imageAtScale(scale: self.scale * .spriteScale)
                            .brightness(0.15)
                    }
                }
                .scaleEffect(x: (isMirrored && !playerImage.isPaddingMirrored)  || (!isMirrored && playerImage.isPaddingMirrored) ? -1 : 1, y: 1)
                .padding(.horizontal)
                .animation(animate ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : animationType)
                
            }
            if(self.isMirrored){
                Spacer()
            }
        }
    }
}


struct StandingToThrowingView: View{
    let player: Player
    @State var scale: Double = 1.0
    @State var isMirrored: Bool = false
    var onTap: (() -> Void)?

    let bounceHaptics = UIImpactFeedbackGenerator(style: .light)
    @State private var animate = false
    @State private var animationType: Animation? = .none
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View{
        let playerImage = self.player.getPlayer()
        HStack{
            
            
            if(!self.isMirrored){
                Spacer()
            }
            Button(action: {
#if !os(macOS)
                bounceHaptics.impactOccurred()
#endif
                self.onTap?()
                if(!self.animate){
                    self.animate.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                        self.animate.toggle()
                    }
                }
            }){
                HStack{
                    
                    
                    ZStack {
                        if !self.animate{
                            AdaptiveImage(colorScheme: self.colorScheme, light: playerImage.baseImage)
                                .imageAtScale(scale: .spriteScale * self.scale * playerImage.baseScale)
                                .padding( playerImage.isPaddingMirrored ? .leading : .trailing, playerImage.horizontalPadding)
                        }
                        else{
                            AdaptiveImage(colorScheme: self.colorScheme, light: playerImage.throwImage ?? playerImage.fightImage)
                                .imageAtScale(scale:  .spriteScale * self.scale * (playerImage.throwScale ?? playerImage.figthScale))
                                .scaleEffect(x: playerImage.isFightImageMirrored ? -1 : 1, y: 1)
                                .padding(.bottom, playerImage.bottomPadding)
                        }
                    }
                    .padding(playerImage.isPaddingMirrored ? .leading : .trailing, 5)
                    .scaleEffect(x: (isMirrored && !playerImage.isPaddingMirrored)  || (!isMirrored && playerImage.isPaddingMirrored) ? -1 : 1, y: 1)
                    .animation(animate ? .none : animationType)
                    
                }
            }
            if(self.isMirrored){
                Spacer()
            }
        }
    }
}


#Preview {
    ScrollView{
        ForEach(Player.allCases){ player in
            BlinkingStandingView(player: player, isMirrored: true)
            StandingToThrowingView(player: player, isMirrored: true)
        }
    }
}
