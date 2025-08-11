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

#Preview {
//    BlinkingView(baseImage: .stephenDodgeSuit, blinkImage: .stephenFighting)
        BlinkingStandingView(baseImage: .stephenSuit, lightImage: .stephenLights)
}
