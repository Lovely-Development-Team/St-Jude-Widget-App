//
//  TapToWobble.swift
//  St Jude
//
//  Created by Ben Cardy on 03/09/2022.
//

import SwiftUI

struct TapToWobble: ViewModifier {
    
    @State private var animate = false
    @State private var animationType: Animation? = .none
    
    let degrees: CGFloat
    let anchor: UnitPoint
    let duration: CGFloat
    
    #if !os(macOS)
    let bounceHaptics = UIImpactFeedbackGenerator(style: .light)
    #endif
    
    func body(content: Content) -> some View {
        Button(action: {
            withAnimation {
#if !os(macOS)
                bounceHaptics.impactOccurred()
#endif
                self.animate.toggle()
                self.animationType = .default
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.animate.toggle()
            }
        }) {
            content
                .rotationEffect(.degrees(animate ? degrees : 0), anchor: anchor)
                .animation(animate ? .easeInOut(duration: duration).repeatForever(autoreverses: true) : animationType)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension View {
    func tapToWobble(degrees: CGFloat = -5, anchor: UnitPoint = .bottomLeading, duration: CGFloat = 0.15) -> some View {
        modifier(TapToWobble(degrees: degrees, anchor: anchor, duration: duration))
    }
}
