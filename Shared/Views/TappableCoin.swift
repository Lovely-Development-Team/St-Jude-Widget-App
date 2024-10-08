//
//  TappableCoin.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/15/24.
//

import SwiftUI

struct TappableCoin: View, Identifiable {
    var id = UUID()
    
    var easterEggEnabled2024: Bool
    
    @State private var shown: Bool = true
    @State private var idleImage = AdaptiveImage.coin(colorScheme: .light)
    @State private var images = AdaptiveImage.coinAnimation(colorScheme: .light)
    var collectable: Bool = true
    var returns: Bool = false
    var spinOnceOnTap: Bool = false
    var offset: Double = -10
    @State private var manualAnimating: Bool = false
    var interval: Double = 0.2
    
    @AppStorage(UserDefaults.coinCountKey, store: UserDefaults.shared) private var coinCount: Int = 0
    
    var body: some View {
        Group {
            if !self.spinOnceOnTap {
                Button {
                    withAnimation(.easeIn) {
                        if self.collectable {
                            self.shown = false
                            if self.returns {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    self.shown = true
                                }
                            }
                        }
                    }
                    SoundEffectHelper.shared.play(.coin)
                    coinCount += 1
                } label: {
                    AnimatedAdaptiveImage(idleImage: self.idleImage, images: self.images, animating: .constant(true), interval: self.interval)
                }
                .opacity(self.shown ? 1.0 : 0.0)
                .offset(y: self.shown ? self.offset : self.offset-10)
            } else {
                Button {
                    self.manualAnimating = true
                    SoundEffectHelper.shared.play(.coin)
                    coinCount += 1
                } label: {
                    AnimatedAdaptiveImage(idleImage: self.idleImage, images: self.images, animating: self.$manualAnimating, playOnce: true, interval: self.interval)
                }
                .offset(y: self.offset)
            }
        }
        .onAppear {
            self.images = self.easterEggEnabled2024
                ? AdaptiveImage.happyCleaningFaceAnimation(colorScheme: .light)
                : AdaptiveImage.coinAnimation(colorScheme: .light)
            self.idleImage = self.easterEggEnabled2024
                ? AdaptiveImage.happyCleaningFace(colorScheme: .light)
                : AdaptiveImage.coin(colorScheme: .light)
        }
        .onChange(of: self.easterEggEnabled2024, perform: { value in
            self.images = value
                ? AdaptiveImage.happyCleaningFaceAnimation(colorScheme: .light)
                : AdaptiveImage.coinAnimation(colorScheme: .light)
            self.idleImage = value
                ? AdaptiveImage.happyCleaningFace(colorScheme: .light)
                : AdaptiveImage.coin(colorScheme: .light)
        })
    }
}

struct TappableCoinPreviewView: View {
    @State private var easterEgg: Bool = false
    
    var body: some View {
        VStack {
            Text("Infinite")
            HStack {
                TappableCoin(easterEggEnabled2024: self.easterEgg)
            }
            Divider()
            Text("Once")
            HStack {
                TappableCoin(easterEggEnabled2024: self.easterEgg, collectable: false, spinOnceOnTap: true)
            }
            Divider()
            HStack {
                TappableCoin(easterEggEnabled2024: self.easterEgg, collectable: true, returns: true)
            }
            Divider()
            Toggle(isOn: self.$easterEgg, label: {
                Text("Easter egg")
            })
        }
    }
}

#Preview {
    TappableCoinPreviewView()
}
