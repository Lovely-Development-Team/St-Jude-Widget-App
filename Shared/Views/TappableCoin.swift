//
//  TappableCoin.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/15/24.
//

import SwiftUI

struct TappableCoin: View, Identifiable {
    var id = UUID()
    
    @State private var shown: Bool = true
    @State private var idleImage = AdaptiveImage.coin(colorScheme: .light)
    @State private var images = AdaptiveImage.coinAnimation(colorScheme: .light)
    @State var collectable: Bool = true
    @State var spinOnceOnTap: Bool = false
    @State var offset: Double = -10
    @State private var manualAnimating: Bool = false
    @State var interval: Double = 0.2
    
    var body: some View {
        if(!self.spinOnceOnTap) {
            Button(action: {
                withAnimation(.easeIn) {
                    if(self.collectable) {
                        self.shown = false
                    }
                }
            }, label: {
                AnimatedAdaptiveImage(idleImage: self.$idleImage, images: self.$images, animating: .constant(true), interval: self.interval)
            })
            .opacity(self.shown ? 1.0 : 0.0)
            .offset(y: self.shown ? self.offset : self.offset-10)
        } else {
            Button(action: {
                self.manualAnimating = true
            }, label: {
                AnimatedAdaptiveImage(idleImage: self.$idleImage, images: self.$images, animating: self.$manualAnimating, playOnce: true, interval: self.interval)
            })
            .offset(y: self.offset)
        }
    }
}

#Preview {
    VStack {
        Text("Infinite")
        HStack {
            TappableCoin()
        }
        Divider()
        Text("Once")
        TappableCoin(collectable: false, spinOnceOnTap: true)
    }
}
