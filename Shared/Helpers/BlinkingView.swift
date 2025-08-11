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
    var ThrowImage: ImageResource
    var FigthImage: ImageResource
    var ThrowScale: Double
    var BaseScale: Double
    var FigthScale: Double
    var isPaddingMirrored: Bool
    var Padding: Double = 30.0
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
    @State var baseImage: ImageResource
    @State var throwImage: ImageResource
    @State var throwBlinkImage: ImageResource?
    @State var scale: Double = 1
    @State var isMirrored: Bool = false
    @State var isPaddingMirrored = false
    
    @State private var test = true
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
                if self.isMirrored{
                    Spacer()
                }
                
                ZStack {
                    if !self.animate{
                        AdaptiveImage(colorScheme: self.colorScheme, light: self.baseImage)
                            .imageAtScale(scale: .spriteScale * self.scale * 0.20)
                            .padding( self.isPaddingMirrored ? .leading : .trailing, 30)
                    }
                    else{
                        AdaptiveImage(colorScheme: self.colorScheme, light: self.throwImage)
                            .imageAtScale(scale:  .spriteScale * self.scale * 0.25)
                            .padding(.vertical)
                    }
                }
                .padding()
                .scaleEffect(x: isMirrored ? -1 : 1, y: 1)
                .animation(animate ? .none : animationType)
                
                if !self.isMirrored{
                    Spacer()
                }
            }
        }
    }
}


#Preview {
    StandingToThrowingView(baseImage: .stephenSuit, throwImage: .stephenDodgeSuit, isMirrored: false, isPaddingMirrored: true)
}
