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
    
    @State private var animating: Bool = false
    @State private var animationType: Animation? = .none
    @State private var animationDuration = 1.0
    
    @State private var animationTimer: Timer?
    let bounceHaptics = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        Button(action: {
            self.animationTimer?.invalidate()
            withAnimation {
                #if !os(macOS)
                bounceHaptics.impactOccurred()
                #endif
                
                self.onTap?()
                self.animating = true
                self.animationType = .default
                self.animationTimer = Timer.scheduledTimer(withTimeInterval: self.animationDuration, repeats: false, block: {_ in
                    self.animating = false
                })
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
