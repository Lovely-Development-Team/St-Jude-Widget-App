//
//  EasterEggImage.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/4/24.
//

import SwiftUI

struct EasterEggImage<Content: View>: View {
    @ViewBuilder var content: Content
    
    var onTap: (() -> Void)?
    
    @State var animating: Bool = false
    @State var animationType: Animation? = .none
    @State var animationDuration = 1.0
    
    let bounceHaptics = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        Button(action: {
            withAnimation {
                guard !self.animating else {
                    return
                }
                
                #if !os(macOS)
                bounceHaptics.impactOccurred()
                #endif
                
                self.onTap?()
                self.animating = true
                self.animationType = .default
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now()+self.animationDuration) {
                self.animating = false
            }
        }, label: {
            content
        })
        .buttonStyle(PlainButtonStyle())
        .offset(x: 0, y: self.animating ? -5 : 0)
        .animation(self.animating ? .easeInOut(duration: 0.15).repeatForever(autoreverses: true) : self.animationType,
                   value: self.animating)
    }
}
